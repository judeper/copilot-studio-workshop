[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-manifest.json'),

    [Parameter()]
    [switch]$ValidateOnly,

    [Parameter()]
    [switch]$CreateEnvironment,

    [Parameter()]
    [switch]$SkipSharedPrereqs,

    [Parameter()]
    [switch]$SkipValidation,

    [Parameter()]
    [switch]$SkipRepair,

    [Parameter()]
    [ValidateSet('FullCopy', 'MinimalCopy')]
    [string]$CopyType = 'FullCopy',

    [Parameter()]
    [ValidateRange(1, 240)]
    [int]$MaxAsyncWaitTimeMinutes = 120,

    [Parameter()]
    [switch]$SkipAuditData
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

function Get-PacEnvironmentByUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl
    )

    $normalizedEnvironmentUrl = Normalize-EnvironmentUrl -Value $EnvironmentUrl
    $matches = @(
        Get-PacEnvironmentListJson |
            Where-Object {
                $candidateUrl = $null
                if ($_.PSObject.Properties.Match('EnvironmentUrl').Count -gt 0) {
                    $candidateUrl = [string]$_.EnvironmentUrl
                }
                elseif ($_.PSObject.Properties.Match('environmentUrl').Count -gt 0) {
                    $candidateUrl = [string]$_.environmentUrl
                }

                (Normalize-EnvironmentUrl -Value $candidateUrl) -eq $normalizedEnvironmentUrl
            }
    )

    if ($matches.Count -lt 1) {
        throw "Unable to resolve environment metadata for '$EnvironmentUrl' from 'pac admin list --json'."
    }

    if ($matches.Count -gt 1) {
        throw "Multiple environments matched '$EnvironmentUrl'. Resolve the ambiguity before running the fallback build."
    }

    return $matches[0]
}

function Test-PacEnvironmentDataverseAccessible {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl
    )

    $output = Invoke-NativeCommandWithOutput -FilePath 'pac' -Arguments @('org', 'who', '--environment', $EnvironmentUrl) -FailureMessage "Unable to probe Dataverse availability for '$EnvironmentUrl'."
    if ($output -match 'currently disabled' -or
        $output -match 'Could not connect to the Dataverse organization' -or
        $output -match 'Operation returned an invalid status code ''NotFound''' -or
        $output -match '(?m)^\s*Error:') {
        return $false
    }

    return $true
}

function Test-DataverseWebApiAccessible {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl
    )

    try {
        $clientContext = New-DataverseClientContext `
            -Config $Config `
            -EnvironmentUrl $EnvironmentUrl `
            -EnsureApplicationUserPresent

        [void](Invoke-DataverseWebApiRequest `
            -EnvironmentUrl $EnvironmentUrl `
            -AccessToken $clientContext.AccessToken `
            -RelativeUri 'WhoAmI()')

        return [pscustomobject]@{
            IsAccessible = $true
            Message      = $null
        }
    }
    catch {
        return [pscustomobject]@{
            IsAccessible = $false
            Message      = [string]$_.Exception.Message
        }
    }
}

function Wait-ForTargetDataverseAfterCopy {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [int]$MaxWaitTimeMinutes
    )

    $overallDeadline = (Get-Date).AddMinutes($MaxWaitTimeMinutes)
    $transitionWaitMinutes = [Math]::Min([Math]::Max([int][Math]::Ceiling($MaxWaitTimeMinutes / 6.0), 2), 10)
    $transitionDeadline = (Get-Date).AddMinutes($transitionWaitMinutes)
    $observedUnavailable = $false

    while ((Get-Date) -lt $transitionDeadline) {
        if (-not (Test-PacEnvironmentDataverseAccessible -EnvironmentUrl $EnvironmentUrl)) {
            $observedUnavailable = $true
            Write-StepResult -Level INFO -Message 'Observed the target Dataverse enter maintenance mode while the environment copy was in progress.'
            break
        }

        Start-Sleep -Seconds 15
    }

    if (-not $observedUnavailable) {
        Write-StepResult -Level WARN -Message "Did not observe the target Dataverse enter maintenance mode within $transitionWaitMinutes minute(s). Waiting for Dataverse Web API readiness anyway."
    }

    $reportedWarmup = $false
    $lastDataverseProbeMessage = $null
    while ((Get-Date) -lt $overallDeadline) {
        if (-not (Test-PacEnvironmentDataverseAccessible -EnvironmentUrl $EnvironmentUrl)) {
            Start-Sleep -Seconds 30
            continue
        }

        $dataverseProbe = Test-DataverseWebApiAccessible -Config $Config -EnvironmentUrl $EnvironmentUrl
        if ($dataverseProbe.IsAccessible) {
            Write-StepResult -Level PASS -Message 'Target Dataverse Web API is reachable again after the environment copy.'
            return
        }

        $lastDataverseProbeMessage = $dataverseProbe.Message
        if (-not $reportedWarmup) {
            Write-StepResult -Level INFO -Message 'pac can reach the target environment again, but the Dataverse Web API is still warming up. Waiting for a successful Web API probe before repair and validation.'
            $reportedWarmup = $true
        }

        Start-Sleep -Seconds 30
    }

    if ([string]::IsNullOrWhiteSpace($lastDataverseProbeMessage)) {
        throw "Target Dataverse Web API did not become reachable again within $MaxWaitTimeMinutes minute(s) after the copy started."
    }

    throw "Target Dataverse Web API did not become reachable again within $MaxWaitTimeMinutes minute(s) after the copy started. Last probe error: $lastDataverseProbeMessage"
}

Write-Section "Loading facilitator fallback configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
Require-Command -Name 'pac'

$fallbackConfig = if ($config.PSObject.Properties.Match('FacilitatorFallback').Count -gt 0) {
    $config.FacilitatorFallback
}
else {
    $null
}
if ($null -eq $fallbackConfig) {
    throw "Config section 'FacilitatorFallback' is required for the fallback build. Copy the section from workshop-config.example.json and set the gold source environment URL."
}

$sourceEnvironmentUrl = Get-RequiredString -Value (Get-OptionalConfigString -Value $fallbackConfig.SourceEnvironmentUrl) -Name 'FacilitatorFallback.SourceEnvironmentUrl'

if (-not $PSBoundParameters.ContainsKey('CopyType')) {
    if ($fallbackConfig.PSObject.Properties.Match('CopyType').Count -gt 0) {
        $configuredCopyType = Get-OptionalConfigString -Value $fallbackConfig.CopyType
        if ($configuredCopyType -in @('FullCopy', 'MinimalCopy')) {
            $CopyType = $configuredCopyType
        }
    }
}

if (-not $PSBoundParameters.ContainsKey('MaxAsyncWaitTimeMinutes')) {
    if ($fallbackConfig.PSObject.Properties.Match('MaxAsyncWaitTimeMinutes').Count -gt 0) {
        $configuredWaitTimeValue = $fallbackConfig.MaxAsyncWaitTimeMinutes | ForEach-Object { $_ }
        if ($null -ne $configuredWaitTimeValue) {
            $configuredWaitTime = [int]$configuredWaitTimeValue
            if ($configuredWaitTime -ge 1) {
                $MaxAsyncWaitTimeMinutes = $configuredWaitTime
            }
        }
    }
}

$skipAuditDataEffective = $SkipAuditData.IsPresent
if (-not $PSBoundParameters.ContainsKey('SkipAuditData') -and $fallbackConfig.PSObject.Properties.Match('SkipAuditData').Count -gt 0) {
    $skipAuditDataEffective = [bool]$fallbackConfig.SkipAuditData
}

if ($CreateEnvironment) {
    Write-Section "Resolving the facilitator fallback environment"
    $environmentParameters = @{
        ConfigPath = $ConfigPath
    }

    if (-not $ValidateOnly) {
        $environmentParameters.CreateEnvironment = $true
        $environmentParameters.UpdateConfig = $true
    }

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-WorkshopPowerPlatformEnvironment.ps1') @environmentParameters
    $config = Get-WorkshopConfig -Path $ConfigPath
}

$configuredTargetEnvironmentUrl = Get-OptionalConfigString -Value $config.EnvironmentUrl
if ($ValidateOnly -and $CreateEnvironment -and (Test-PlaceholderValue -Value $configuredTargetEnvironmentUrl)) {
    if (-not $SkipSharedPrereqs) {
        & (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopLabSetup.ps1') -ConfigPath $ConfigPath -Mode StudentReady -ValidateOnly
    }

    Write-Section "Validated facilitator fallback prerequisites"
    Write-StepResult -Level INFO -Message 'The target facilitator fallback environment URL will be resolved when you run this script without -ValidateOnly.'
    return
}

$targetEnvironmentUrl = Get-RequiredString -Value $configuredTargetEnvironmentUrl -Name 'EnvironmentUrl'

if ($sourceEnvironmentUrl.TrimEnd('/') -eq $targetEnvironmentUrl.TrimEnd('/')) {
    throw "FacilitatorFallback.SourceEnvironmentUrl must point to a separate gold source environment. It currently matches EnvironmentUrl."
}

Write-StepResult -Level INFO -Message "Gold source environment: $sourceEnvironmentUrl"
Write-StepResult -Level INFO -Message "Target fallback environment: $targetEnvironmentUrl"

$artifactPath = Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-artifacts.json'
$repairReportPath = Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-repair-report.json'
$sourceEnvironmentRecord = Get-PacEnvironmentByUrl -EnvironmentUrl $sourceEnvironmentUrl
$targetEnvironmentRecord = Get-PacEnvironmentByUrl -EnvironmentUrl $targetEnvironmentUrl
$sourceEnvironmentId = Get-RequiredString -Value ([string]$sourceEnvironmentRecord.EnvironmentId) -Name 'source environment id'
$targetEnvironmentId = Get-RequiredString -Value ([string]$targetEnvironmentRecord.EnvironmentId) -Name 'target environment id'
$targetEnvironmentDisplayName = Get-RequiredString -Value ([string]$targetEnvironmentRecord.DisplayName) -Name 'target environment display name'

if (-not $SkipSharedPrereqs) {
    Write-Section "Ensuring shared workshop prerequisites"
    $sharedPrereqParameters = @{
        ConfigPath = $ConfigPath
        Mode       = 'StudentReady'
    }

    if ($ValidateOnly) {
        $sharedPrereqParameters.ValidateOnly = $true
    }

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopLabSetup.ps1') @sharedPrereqParameters
}

Write-Section "Packaging facilitator artifact layers"
& (Join-Path -Path $PSScriptRoot -ChildPath 'Export-WorkshopFacilitatorArtifactLayers.ps1') `
    -ConfigPath $ConfigPath `
    -ManifestPath $ManifestPath `
    -EnvironmentUrl $sourceEnvironmentUrl `
    -OutputPath $artifactPath

if ($ValidateOnly) {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopFacilitatorFallbackValidation.ps1') -ConfigPath $ConfigPath -ManifestPath $ManifestPath -ValidateOnly
    Write-Section "Validated facilitator fallback build inputs"
    Write-StepResult -Level INFO -Message 'No environment copy was performed because -ValidateOnly was supplied.'
    return
}

Write-Section "Copying the gold facilitator environment"
$copyArguments = @(
    'admin',
    'copy',
    '--source-env',
    $sourceEnvironmentId,
    '--target-env',
    $targetEnvironmentId,
    '--name',
    $targetEnvironmentDisplayName,
    '--type',
    $CopyType,
    '--async',
    '--max-async-wait-time',
    "$MaxAsyncWaitTimeMinutes"
)

if ($skipAuditDataEffective) {
    $copyArguments += '--skip-audit-data'
}

if ($PSCmdlet.ShouldProcess($targetEnvironmentUrl, "Copy facilitator fallback environment from $sourceEnvironmentUrl")) {
    $copyOutput = Invoke-NativeCommandWithOutput -FilePath 'pac' -Arguments $copyArguments -FailureMessage 'Facilitator fallback environment copy failed.'
    if (-not [string]::IsNullOrWhiteSpace($copyOutput)) {
        $copyOutput.TrimEnd() | Write-Host
    }

    if ($copyOutput -match '(?m)^\s*Error:' -or $copyOutput -match 'The environment display name property is null or empty') {
        throw "Facilitator fallback environment copy did not complete successfully.`n$copyOutput"
    }

    Wait-ForTargetDataverseAfterCopy -Config $config -EnvironmentUrl $targetEnvironmentUrl -MaxWaitTimeMinutes $MaxAsyncWaitTimeMinutes
     
    Write-Section "Selecting the rebuilt facilitator environment"
    Invoke-NativeCommand -FilePath 'pac' -Arguments @('org', 'select', '--environment', $targetEnvironmentUrl) -FailureMessage 'Unable to select the rebuilt facilitator fallback environment in pac.'
    Write-StepResult -Level PASS -Message 'Selected the rebuilt facilitator fallback environment in pac.'

    if (-not $SkipRepair) {
        Write-Section "Repairing environment-bound bindings"
        & (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopFacilitatorBindingRepair.ps1') `
            -ConfigPath $ConfigPath `
            -ArtifactPath $artifactPath `
            -ReportPath $repairReportPath `
            -EnvironmentUrl $targetEnvironmentUrl
    }
     
    if (-not $SkipValidation) {
        & (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopFacilitatorFallbackValidation.ps1') -ConfigPath $ConfigPath -ManifestPath $ManifestPath
    }
}
else {
    Write-StepResult -Level INFO -Message 'Skipped the environment copy because -WhatIf was supplied.'
}

Write-Section "Recommended next steps"
Write-StepResult -Level INFO -Message 'Complete the manual lab spot-checks from the validation script before using the fallback environment live.'
Write-StepResult -Level INFO -Message "Review '$repairReportPath' after each rebuild so repairable labs are confirmed before delivery."
Write-StepResult -Level INFO -Message 'Keep the gold source environment facilitator-only and separate from student hands-on environments.'
