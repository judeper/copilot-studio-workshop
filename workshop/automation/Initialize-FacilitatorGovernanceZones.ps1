<#
.SYNOPSIS
    Facilitator-only setup helper for the combined ALM + Governance module's
    Three-Zones demo (PowerCAT teaching pattern).

.DESCRIPTION
    Validates that the three demo Power Platform environments referenced by
    Governance.PersonalSandboxEnvironmentUrl, TeamDevEnvironmentUrl, and
    ProductionEnvironmentUrl exist, are visible to the configured pac CLI
    profile, and have Dataverse provisioned. Prints a summary table of zone
    state.

    THIS IS FACILITATOR DEMO ONLY. Students are NOT provisioned three
    environments — the Three-Zones content is a concept lecture plus a
    facilitator-driven demo. Do not adapt this script into the student
    provisioning path.

    Future scope (out of scope here):
      -CreatePersonalSandbox switch to bootstrap the personal sandbox env.

.PARAMETER ConfigPath
    Path to workshop-config.json. Defaults to the file next to this script.

.PARAMETER ValidateOnly
    Default behavior. Reserved for symmetry with other facilitator scripts —
    no destructive operations are ever performed by this script today.

.EXAMPLE
    pwsh -File .\workshop\automation\Initialize-FacilitatorGovernanceZones.ps1

.EXAMPLE
    pwsh -File .\workshop\automation\Initialize-FacilitatorGovernanceZones.ps1 -ValidateOnly
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

Initialize-WorkshopLog -ScriptName 'Initialize-FacilitatorGovernanceZones'

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
Assert-FacilitatorOnlyEnvironment -Config $config

if (-not ($config.PSObject.Properties.Name -contains 'Governance') -or -not $config.Governance) {
    throw "Config is missing the 'Governance' section. Add Governance.PersonalSandboxEnvironmentUrl, TeamDevEnvironmentUrl, ProductionEnvironmentUrl, and ALMSolutionDownloadUrl per workshop-config.example.json."
}

$governance = $config.Governance

$enableThreeZones = $false
if ($governance.PSObject.Properties.Name -contains 'EnableThreeZonesDemo') {
    $enableThreeZones = [bool]$governance.EnableThreeZonesDemo
}
if (-not $enableThreeZones) {
    Write-StepResult -Level WARN -Message "Governance.EnableThreeZonesDemo is false. Continuing in validate-only mode so facilitators can still confirm zone readiness, but the demo is gated off."
}

$zones = @(
    [pscustomobject]@{ Name = 'Personal Sandbox'; ConfigKey = 'Governance.PersonalSandboxEnvironmentUrl'; Url = [string]$governance.PersonalSandboxEnvironmentUrl }
    [pscustomobject]@{ Name = 'Team Dev';         ConfigKey = 'Governance.TeamDevEnvironmentUrl';         Url = [string]$governance.TeamDevEnvironmentUrl }
    [pscustomobject]@{ Name = 'Production';       ConfigKey = 'Governance.ProductionEnvironmentUrl';       Url = [string]$governance.ProductionEnvironmentUrl }
)

Write-Section "Validating Governance zone config"
foreach ($zone in $zones) {
    if (Test-PlaceholderValue -Value $zone.Url) {
        throw "Config value '$($zone.ConfigKey)' is still a placeholder. Set it to the demo environment URL before running the Three-Zones demo."
    }
    Write-StepResult -Level PASS -Message "$($zone.Name) → $($zone.Url)"
}

$almUrl = [string]$governance.ALMSolutionDownloadUrl
if (Test-PlaceholderValue -Value $almUrl) {
    Write-StepResult -Level WARN -Message "Governance.ALMSolutionDownloadUrl is still a placeholder. Take-home solution.zip link will not be shown to participants."
}
else {
    Write-StepResult -Level PASS -Message "ALM take-home solution download URL configured: $almUrl"
}

Write-Section "Querying pac admin list"
Require-Command -Name 'pac'

$pacEnvironments = @()
try {
    $pacEnvironments = @(Get-PacEnvironmentListJson)
}
catch {
    throw "Unable to enumerate Power Platform environments via 'pac admin list --json'. Run 'pac auth list' / 'pac auth create' as a Power Platform admin first. Underlying error: $($_.Exception.Message)"
}

Write-StepResult -Level PASS -Message "pac admin list returned $($pacEnvironments.Count) environment(s)."

function Find-PacEnvironmentByUrl {
    param(
        [Parameter(Mandatory = $true)][object[]]$Environments,
        [Parameter(Mandatory = $true)][string]$Url
    )
    $normalized = $Url.Trim().TrimEnd('/').ToLowerInvariant()
    return @(
        $Environments | Where-Object {
            $candidate = [string]$_.EnvironmentUrl
            if ([string]::IsNullOrWhiteSpace($candidate)) { return $false }
            return ($candidate.Trim().TrimEnd('/').ToLowerInvariant() -eq $normalized)
        } | Select-Object -First 1
    )
}

Write-Section "Three-Zones environment summary"
$summaryRows = foreach ($zone in $zones) {
    $match = Find-PacEnvironmentByUrl -Environments $pacEnvironments -Url $zone.Url
    $found = $false
    $type = ''
    $dataverse = $false
    $envId = ''
    if ($match) {
        $found = $true
        $type = [string]$match.Type
        $envId = [string]$match.EnvironmentId
        # pac admin list reports DataverseOrganizationId / IsDataverseEnabled inconsistently
        # across versions; treat any non-empty environment URL as Dataverse-enabled because
        # only Dataverse-backed envs have an org URL.
        $dataverse = -not [string]::IsNullOrWhiteSpace([string]$match.EnvironmentUrl)
    }

    [pscustomobject]@{
        Zone        = $zone.Name
        Url         = $zone.Url
        Found       = $found
        Type        = $type
        Dataverse   = $dataverse
        EnvironmentId = $envId
    }
}

$summaryRows | Format-Table -AutoSize | Out-String | Write-Host

$missing = @($summaryRows | Where-Object { -not $_.Found })
if ($missing.Count -gt 0) {
    foreach ($row in $missing) {
        Write-StepResult -Level WARN -Message "Zone '$($row.Zone)' env '$($row.Url)' was NOT found by pac. Confirm pac is authenticated as an admin who can see it, or create the environment."
    }
}
else {
    Write-StepResult -Level PASS -Message "All three Three-Zones demo environments are visible to pac and Dataverse-backed."
}

if ($ValidateOnly) {
    Write-StepResult -Level INFO -Message "ValidateOnly: no provisioning actions performed (this script is validate-only today)."
}

Write-Section "Done"
Write-StepResult -Level INFO -Message "Three-Zones is a PowerCAT teaching pattern, not Microsoft official guidance. Anchor the demo to GLBA Safeguards / NYDFS Part 500 §500.11 / OCC AI guidance / EU AI Act Annex III §5(b) per the facilitator guide."
