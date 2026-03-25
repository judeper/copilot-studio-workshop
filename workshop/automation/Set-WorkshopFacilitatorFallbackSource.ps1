[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'ExplicitSource')]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-manifest.json'),

    [Parameter(Mandatory = $true, ParameterSetName = 'ListCandidates')]
    [switch]$ListCandidates,

    [Parameter(ParameterSetName = 'ListCandidates')]
    [string]$CandidateFilter,

    [Parameter(Mandatory = $true, ParameterSetName = 'ExplicitSource')]
    [string]$SourceEnvironmentUrl,

    [Parameter(Mandatory = $true, ParameterSetName = 'ConfiguredSource')]
    [switch]$UseConfiguredEnvironment,

    [Parameter(ParameterSetName = 'ExplicitSource')]
    [Parameter(ParameterSetName = 'ConfiguredSource')]
    [switch]$UpdateConfig
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Normalize-EnvironmentUrl {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return $Value.Trim().TrimEnd('/')
}

function Get-ConfiguredFallbackSourceEnvironmentUrl {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    if ($Config.PSObject.Properties.Match('FacilitatorFallback').Count -eq 0 -or $null -eq $Config.FacilitatorFallback) {
        return $null
    }

    $candidate = Get-OptionalConfigString -Value $Config.FacilitatorFallback.SourceEnvironmentUrl
    if ([string]::IsNullOrWhiteSpace($candidate) -or (Test-PlaceholderValue -Value $candidate)) {
        return $null
    }

    return Normalize-EnvironmentUrl -Value $candidate
}

function Get-ConfiguredTargetEnvironmentUrl {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    $candidate = Get-OptionalConfigString -Value $Config.EnvironmentUrl
    if ([string]::IsNullOrWhiteSpace($candidate) -or (Test-PlaceholderValue -Value $candidate)) {
        return $null
    }

    return Normalize-EnvironmentUrl -Value $candidate
}

function Get-CandidateEnvironmentRows {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Filter
    )

    $configuredTargetEnvironmentUrl = Get-ConfiguredTargetEnvironmentUrl -Config $Config
    $configuredSourceEnvironmentUrl = Get-ConfiguredFallbackSourceEnvironmentUrl -Config $Config

    $candidateEnvironments = @(
        Get-PacEnvironmentListJson |
            Where-Object { [string]$_.Type -in @('Sandbox', 'Developer', 'Production') }
    )

    if (-not [string]::IsNullOrWhiteSpace($Filter)) {
        try {
            $regex = [regex]::new($Filter, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }
        catch {
            throw "CandidateFilter '$Filter' is not a valid regex: $($_.Exception.Message)"
        }

        $candidateEnvironments = @(
            $candidateEnvironments |
                Where-Object {
                    $regex.IsMatch([string]$_.DisplayName) -or
                    $regex.IsMatch([string]$_.EnvironmentUrl)
                }
        )
    }

    return @(
        $candidateEnvironments |
            Sort-Object -Property DisplayName, EnvironmentUrl |
            ForEach-Object {
                $environmentUrl = Normalize-EnvironmentUrl -Value ([string]$_.EnvironmentUrl)
                [pscustomobject]@{
                    DisplayName        = [string]$_.DisplayName
                    Type               = [string]$_.Type
                    EnvironmentUrl     = $environmentUrl
                    IsConfiguredTarget = ($null -ne $configuredTargetEnvironmentUrl -and $environmentUrl -eq $configuredTargetEnvironmentUrl)
                    IsConfiguredSource = ($null -ne $configuredSourceEnvironmentUrl -and $environmentUrl -eq $configuredSourceEnvironmentUrl)
                }
            }
    )
}

Write-Section "Loading facilitator fallback source inputs"
$config = Get-WorkshopConfig -Path $ConfigPath
Require-Command -Name 'pac'

if ($ListCandidates) {
    Write-Section "Listing candidate gold source environments"
    $candidateRows = @(Get-CandidateEnvironmentRows -Config $config -Filter $CandidateFilter)
    if ($candidateRows.Count -lt 1) {
        throw 'No facilitator fallback source candidates matched the current filter.'
    }

    ($candidateRows | Format-Table -AutoSize | Out-String).TrimEnd() | Write-Host

    Write-Section "Recommended next steps"
    Write-StepResult -Level INFO -Message 'Run Set-WorkshopFacilitatorFallbackSource.ps1 -SourceEnvironmentUrl <url> to qualify a specific gold source candidate.'
    Write-StepResult -Level INFO -Message 'Add -UpdateConfig when you want to persist the selected gold source URL into FacilitatorFallback.SourceEnvironmentUrl.'
    return
}

$configuredTargetEnvironmentUrl = Get-ConfiguredTargetEnvironmentUrl -Config $config
$configuredSourceEnvironmentUrl = Get-ConfiguredFallbackSourceEnvironmentUrl -Config $config

$selectedSourceEnvironmentUrl = switch ($PSCmdlet.ParameterSetName) {
    'ConfiguredSource' {
        Normalize-EnvironmentUrl -Value (Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl')
        break
    }
    default {
        Normalize-EnvironmentUrl -Value (Get-RequiredString -Value $SourceEnvironmentUrl -Name 'SourceEnvironmentUrl')
        break
    }
}

Write-StepResult -Level INFO -Message "Environment under qualification: $selectedSourceEnvironmentUrl"
if ($null -ne $configuredTargetEnvironmentUrl) {
    Write-StepResult -Level INFO -Message "Configured fallback target environment: $configuredTargetEnvironmentUrl"
}
if ($null -ne $configuredSourceEnvironmentUrl) {
    Write-StepResult -Level INFO -Message "Configured gold source environment: $configuredSourceEnvironmentUrl"
}

if ($null -ne $configuredTargetEnvironmentUrl -and $configuredTargetEnvironmentUrl -eq $selectedSourceEnvironmentUrl) {
    Write-StepResult -Level WARN -Message 'The current EnvironmentUrl matches the source candidate. That is acceptable for qualification, but before running the fallback build you must point EnvironmentUrl at a separate facilitator-owned target environment.'
}

Write-Section "Validating the gold source candidate"
& (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopFacilitatorFallbackValidation.ps1') `
    -ConfigPath $ConfigPath `
    -ManifestPath $ManifestPath `
    -EnvironmentUrl $selectedSourceEnvironmentUrl

Write-Section "Gold source qualification passed"
Write-StepResult -Level PASS -Message 'The selected environment passed the facilitator fallback validation suite.'

if ($UpdateConfig) {
    if ($config.PSObject.Properties.Match('FacilitatorFallback').Count -eq 0 -or $null -eq $config.FacilitatorFallback) {
        $config | Add-Member -NotePropertyName 'FacilitatorFallback' -NotePropertyValue ([pscustomobject]@{}) -Force
    }

    if ($config.FacilitatorFallback.PSObject.Properties.Match('SourceEnvironmentUrl').Count -eq 0) {
        $config.FacilitatorFallback | Add-Member -NotePropertyName 'SourceEnvironmentUrl' -NotePropertyValue $selectedSourceEnvironmentUrl
    }
    else {
        $config.FacilitatorFallback.SourceEnvironmentUrl = $selectedSourceEnvironmentUrl
    }

    if ($config.FacilitatorFallback.PSObject.Properties.Match('CopyType').Count -eq 0) {
        $config.FacilitatorFallback | Add-Member -NotePropertyName 'CopyType' -NotePropertyValue 'FullCopy'
    }

    if ($config.FacilitatorFallback.PSObject.Properties.Match('MaxAsyncWaitTimeMinutes').Count -eq 0) {
        $config.FacilitatorFallback | Add-Member -NotePropertyName 'MaxAsyncWaitTimeMinutes' -NotePropertyValue 120
    }

    if ($config.FacilitatorFallback.PSObject.Properties.Match('SkipAuditData').Count -eq 0) {
        $config.FacilitatorFallback | Add-Member -NotePropertyName 'SkipAuditData' -NotePropertyValue $false
    }

    if ($PSCmdlet.ShouldProcess($ConfigPath, "Set FacilitatorFallback.SourceEnvironmentUrl to $selectedSourceEnvironmentUrl")) {
        Save-WorkshopConfig -Path $ConfigPath -Config $config
        Write-StepResult -Level PASS -Message "Saved FacilitatorFallback.SourceEnvironmentUrl = '$selectedSourceEnvironmentUrl'."
    }
    else {
        Write-StepResult -Level INFO -Message 'Skipped saving the gold source URL because -WhatIf was supplied.'
    }
}

Write-Section "Recommended next steps"
if ($null -eq $configuredTargetEnvironmentUrl -or $configuredTargetEnvironmentUrl -eq $selectedSourceEnvironmentUrl) {
    Write-StepResult -Level WARN -Message 'Before running the fallback build, set EnvironmentUrl to a separate facilitator-owned target environment or use a separate config file for the target.'
}
else {
    Write-StepResult -Level INFO -Message 'Run Invoke-WorkshopFacilitatorFallbackBuild.ps1 when you are ready to refresh the separate facilitator fallback target from this source.'
}

