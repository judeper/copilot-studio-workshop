[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-manifest.json'),

    [Parameter()]
    [string]$EnvironmentUrl,

    [Parameter()]
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Get-FacilitatorFallbackManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Fallback manifest '$Path' was not found."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100
}

function Get-PacAggregateValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text,

        [Parameter(Mandatory = $true)]
        [string]$Alias
    )

    $lines = @(
        $Text -split '\r?\n' |
            ForEach-Object { $_.Trim() } |
            Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    )

    for ($index = 0; $index -lt ($lines.Count - 1); $index++) {
        if ($lines[$index] -eq $Alias -and $lines[$index + 1] -match '^\d+$') {
            return [int]$lines[$index + 1]
        }
    }

    throw "Unable to parse the aggregate value '$Alias' from pac org fetch output."
}

function Get-FetchAggregateCount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [psobject]$Check
    )

    $output = Invoke-NativeCommandWithOutput `
        -FilePath 'pac' `
        -Arguments @('org', 'fetch', '--environment', $EnvironmentUrl, '--xml', [string]$Check.fetchXml) `
        -FailureMessage "Failed to run Dataverse validation check '$([string]$Check.id)'."

    if ($output -match '(?m)^\s*No results returned\.\s*$') {
        return 0
    }

    if ($output -match '(?m)^\s*Error:' -or $output -match 'entity with a name = ') {
        return 0
    }

    return Get-PacAggregateValue -Text $output -Alias ([string]$Check.alias)
}

Write-Section "Loading facilitator fallback validation inputs"
$config = Get-WorkshopConfig -Path $ConfigPath
Assert-FacilitatorOnlyEnvironment -Config $config
$manifest = Get-FacilitatorFallbackManifest -Path $ManifestPath

Require-Command -Name 'pac'

$validationEnvironmentUrl = if ($PSBoundParameters.ContainsKey('EnvironmentUrl')) {
    Get-RequiredString -Value $EnvironmentUrl -Name 'EnvironmentUrl'
}
else {
    Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'
}

$fallbackConfig = if ($config.PSObject.Properties.Match('FacilitatorFallback').Count -gt 0) {
    $config.FacilitatorFallback
}
else {
    $null
}
$sourceEnvironmentUrl = $null
if ($null -ne $fallbackConfig) {
    $configuredSourceEnvironmentUrl = Get-OptionalConfigString -Value $fallbackConfig.SourceEnvironmentUrl
    if (-not [string]::IsNullOrWhiteSpace($configuredSourceEnvironmentUrl) -and -not (Test-PlaceholderValue -Value $configuredSourceEnvironmentUrl)) {
        $sourceEnvironmentUrl = $configuredSourceEnvironmentUrl.TrimEnd('/')
    }
}

if ($null -ne $sourceEnvironmentUrl) {
    Write-StepResult -Level INFO -Message "Configured gold source environment: $sourceEnvironmentUrl"
}
Write-StepResult -Level INFO -Message "Environment under validation: $validationEnvironmentUrl"

Invoke-NativeCommand -FilePath 'pac' -Arguments @('org', 'select', '--environment', $validationEnvironmentUrl) -FailureMessage 'Unable to select the environment under validation in pac.'
Write-StepResult -Level PASS -Message 'Selected the environment under validation in pac.'

if ($ValidateOnly) {
    Write-Section "Validated facilitator fallback inputs"
    Write-StepResult -Level INFO -Message 'No Dataverse checks were executed because -ValidateOnly was supplied.'
    return
}

Write-Section "Running automated facilitator fallback checks"
$failedChecks = [System.Collections.Generic.List[string]]::new()

foreach ($check in @($manifest.automatedChecks)) {
    $minimumCount = [int]$check.minimumCount
    $count = Get-FetchAggregateCount -EnvironmentUrl $validationEnvironmentUrl -Check $check

    if ($count -ge $minimumCount) {
        Write-StepResult -Level PASS -Message ([string]$check.successMessage)
    }
    else {
        $message = "{0} (found {1}, expected at least {2})" -f ([string]$check.failureMessage), $count, $minimumCount
        Write-StepResult -Level WARN -Message $message
        [void]$failedChecks.Add($message)
    }
}

Write-Section "Manual facilitator spot-checks"
foreach ($lab in @($manifest.labs | Sort-Object { [int]$_.labNumber })) {
    $manualChecks = @($lab.manualChecks | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    if ($manualChecks.Count -eq 0) {
        continue
    }

    $labNumber = [int]$lab.labNumber
    Write-StepResult -Level INFO -Message ("Lab {0:D2} - {1}: {2}" -f $labNumber, [string]$lab.title, [string]$lab.validationSummary)
    foreach ($manualCheck in $manualChecks) {
        Write-Host "  - $manualCheck" -ForegroundColor DarkCyan
    }
}

if ($failedChecks.Count -gt 0) {
    throw "Facilitator fallback validation failed. Resolve the missing Dataverse state before relying on this environment.`n$($failedChecks -join [System.Environment]::NewLine)"
}

Write-Section "Facilitator fallback validation passed"
Write-StepResult -Level PASS -Message 'Automated Dataverse checks passed. Complete the manual facilitator spot-checks above before delivery.'
