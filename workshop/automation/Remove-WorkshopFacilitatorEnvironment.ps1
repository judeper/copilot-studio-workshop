[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$EnvironmentUrl,

    [Parameter()]
    [switch]$AllowGoldSourceDeletion,

    [Parameter()]
    [ValidateRange(5, 300)]
    [int]$PollIntervalSeconds = 15,

    [Parameter()]
    [ValidateRange(1, 60)]
    [int]$TimeoutMinutes = 15
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

    if ($matches.Count -gt 1) {
        throw "Multiple environments matched '$EnvironmentUrl'. Resolve the ambiguity before running facilitator cleanup."
    }

    if ($matches.Count -lt 1) {
        return $null
    }

    return $matches[0]
}

function Wait-ForPacEnvironmentDeletion {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [int]$PollIntervalSeconds,

        [Parameter(Mandatory = $true)]
        [int]$TimeoutMinutes
    )

    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    $pollCount = 0

    while ((Get-Date) -lt $deadline) {
        if (-not (Get-PacEnvironmentByUrl -EnvironmentUrl $EnvironmentUrl)) {
            return $true
        }

        $pollCount++
        Write-StepResult -Level INFO -Message "Facilitator environment delete is still in progress (check $pollCount). Waiting ${PollIntervalSeconds}s before rechecking."
        Start-Sleep -Seconds $PollIntervalSeconds
    }

    return -not (Get-PacEnvironmentByUrl -EnvironmentUrl $EnvironmentUrl)
}

Write-Section 'Loading facilitator environment cleanup inputs'
$config = Get-WorkshopConfig -Path $ConfigPath
Require-Command -Name 'pac'

$targetEnvironmentUrl = if ($PSBoundParameters.ContainsKey('EnvironmentUrl')) {
    Get-RequiredString -Value $EnvironmentUrl -Name 'EnvironmentUrl'
}
else {
    Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'
}
$targetEnvironmentUrl = Normalize-EnvironmentUrl -Value $targetEnvironmentUrl

$goldSourceEnvironmentUrl = $null
if ($config.PSObject.Properties.Match('FacilitatorFallback').Count -gt 0 -and
    $null -ne $config.FacilitatorFallback -and
    $config.FacilitatorFallback.PSObject.Properties.Match('SourceEnvironmentUrl').Count -gt 0) {
    $goldSourceEnvironmentUrl = Normalize-EnvironmentUrl -Value ([string]$config.FacilitatorFallback.SourceEnvironmentUrl)
}

Write-StepResult -Level INFO -Message "Facilitator environment under cleanup: $targetEnvironmentUrl"
if (-not [string]::IsNullOrWhiteSpace($goldSourceEnvironmentUrl)) {
    Write-StepResult -Level INFO -Message "Configured facilitator gold source: $goldSourceEnvironmentUrl"
}

if (-not $AllowGoldSourceDeletion -and
    -not [string]::IsNullOrWhiteSpace($goldSourceEnvironmentUrl) -and
    $targetEnvironmentUrl -eq $goldSourceEnvironmentUrl) {
    throw "Refusing to delete the configured facilitator gold source '$goldSourceEnvironmentUrl'. Re-run with -AllowGoldSourceDeletion only if you intentionally want to delete the gold source."
}

$environmentRecord = Get-PacEnvironmentByUrl -EnvironmentUrl $targetEnvironmentUrl
if ($null -eq $environmentRecord) {
    Write-StepResult -Level PASS -Message 'Facilitator environment is already absent.'
    return
}

$environmentDisplayName = if ($environmentRecord.PSObject.Properties.Match('DisplayName').Count -gt 0) {
    [string]$environmentRecord.DisplayName
}
elseif ($environmentRecord.PSObject.Properties.Match('displayName').Count -gt 0) {
    [string]$environmentRecord.displayName
}
else {
    $targetEnvironmentUrl
}

$environmentIdentifier = if ($environmentRecord.PSObject.Properties.Match('EnvironmentId').Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$environmentRecord.EnvironmentId)) {
    [string]$environmentRecord.EnvironmentId
}
elseif ($environmentRecord.PSObject.Properties.Match('environmentId').Count -gt 0 -and -not [string]::IsNullOrWhiteSpace([string]$environmentRecord.environmentId)) {
    [string]$environmentRecord.environmentId
}
else {
    $targetEnvironmentUrl
}

Write-StepResult -Level INFO -Message "Resolved facilitator environment '$environmentDisplayName' for deletion."

if (-not $PSCmdlet.ShouldProcess($targetEnvironmentUrl, "Delete facilitator environment '$environmentDisplayName'")) {
    return
}

$deleteOutput = Invoke-NativeCommandWithOutput `
    -FilePath 'pac' `
    -Arguments @('admin', 'delete', '--environment', $environmentIdentifier, '--async') `
    -FailureMessage 'Unable to submit facilitator environment delete request.'

if (-not [string]::IsNullOrWhiteSpace($deleteOutput)) {
    $deleteOutput.TrimEnd() | Write-Host
}

if ($deleteOutput -match '(?m)^\s*Error:') {
    throw "Facilitator environment delete request did not complete successfully.`n$deleteOutput"
}

Write-StepResult -Level INFO -Message "Delete request submitted. Polling pac admin list every ${PollIntervalSeconds}s for up to ${TimeoutMinutes} minute(s)."
if (-not (Wait-ForPacEnvironmentDeletion -EnvironmentUrl $targetEnvironmentUrl -PollIntervalSeconds $PollIntervalSeconds -TimeoutMinutes $TimeoutMinutes)) {
    throw "Facilitator environment '$targetEnvironmentUrl' was not confirmed deleted within ${TimeoutMinutes} minute(s)."
}

Write-Section 'Facilitator environment cleanup complete'
Write-StepResult -Level PASS -Message "Deleted facilitator environment '$environmentDisplayName'."
