<#
.SYNOPSIS
    Facilitator cleanup: disables autonomous triggers in the configured demo
    environment after the workshop ends so trigger-driven agents do not keep
    firing and burning Copilot Credits.

.DESCRIPTION
    Reads workshop-config.json, asserts the target environment is a facilitator
    demo or fallback environment (Workshop.EnvironmentPurpose), then queries
    Dataverse for Copilot Studio bot trigger components and disables them.

    Bots in Copilot Studio surface as Dataverse 'bot' rows; triggers and other
    authoring artifacts surface as 'botcomponent' rows discriminated by a
    componenttype option set value. Autonomous triggers (event/schedule-based)
    are botcomponent rows whose componenttype identifies them as a trigger
    component. Disable is performed by setting statecode = 1 (Disabled) /
    statuscode = 2 (Inactive) — the same fields the maker UI toggles.

    NOTE / TODO (human follow-up):
      The botcomponent.componenttype option set value for "Trigger" is not
      consistently published in Microsoft Learn. The query below filters on a
      placeholder set of componenttype values (see $TriggerComponentTypeValues
      below). Before relying on this script in production, a facilitator should
      run with -ListOnly against a known demo env, confirm the returned rows
      are the expected autonomous triggers, and adjust the filter list. The
      code path that disables rows already requires -Confirm:$false / -Force
      via SupportsShouldProcess so a dry run is the default safe path.

.PARAMETER ConfigPath
    Path to workshop-config.json. Defaults to the file next to this script.

.PARAMETER ListOnly
    Lists candidate trigger components but does not disable any rows.

.EXAMPLE
    pwsh -File .\workshop\automation\Disable-WorkshopAutonomousTriggers.ps1 -ListOnly

.EXAMPLE
    pwsh -File .\workshop\automation\Disable-WorkshopAutonomousTriggers.ps1 -WhatIf

.EXAMPLE
    pwsh -File .\workshop\automation\Disable-WorkshopAutonomousTriggers.ps1
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$ListOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

# TODO (human follow-up): verify and trim this list once the official
# botcomponent.componenttype option-set value for autonomous triggers is
# confirmed. Values below are best-effort guesses based on the public
# Power Platform sample app for botcomponent ranges — DO NOT trust blindly.
$TriggerComponentTypeValues = @(0, 9, 10)

Initialize-WorkshopLog -ScriptName 'Disable-WorkshopAutonomousTriggers'

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath

# Refuse to run against student or shared environments.
Assert-FacilitatorOnlyEnvironment -Config $config

$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'
$environmentUrl = Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'

$autonomousConfig = $null
if ($config.PSObject.Properties.Name -contains 'Autonomous' -and $config.Autonomous) {
    $autonomousConfig = $config.Autonomous
}

if ($autonomousConfig -and $autonomousConfig.PSObject.Properties.Name -contains 'DisableAfterWorkshop') {
    if (-not [bool]$autonomousConfig.DisableAfterWorkshop) {
        Write-StepResult -Level WARN -Message "Autonomous.DisableAfterWorkshop is false in config. Continuing because the script was invoked explicitly, but the configured intent is to leave triggers enabled."
    }
}

Write-StepResult -Level PASS -Message "Targeting environment '$environmentUrl' (tenant '$tenantId')."

Write-Section "Acquiring Dataverse access token"
$clientContext = Get-WorkshopAppClientContext -Config $config
$accessToken = Get-DataverseAccessToken -TenantId $tenantId -ClientId $clientContext.ClientId -ClientSecret $clientContext.ClientSecret -EnvironmentUrl $environmentUrl
Write-StepResult -Level PASS -Message "Acquired Dataverse access token for '$environmentUrl'."

Write-Section "Querying autonomous trigger components"
# botcomponent fields: botcomponentid, name, componenttype, statecode, statuscode, _parentbotid_value
$componentTypeFilter = ($TriggerComponentTypeValues | ForEach-Object { "componenttype eq $_" }) -join ' or '
$select = '$select=botcomponentid,name,componenttype,statecode,statuscode,_parentbotid_value'
$filter = '$filter=(' + $componentTypeFilter + ') and statecode eq 0'
$relativeUri = "botcomponents?$select&$filter"

$response = $null
try {
    $response = Invoke-DataverseWebApiRequest -EnvironmentUrl $environmentUrl -AccessToken $accessToken -RelativeUri $relativeUri -Method GET
}
catch {
    Write-StepResult -Level WARN -Message "Failed to query botcomponents: $($_.Exception.Message)"
    Write-Log -Level WARN -Message "botcomponents query failed: $($_.Exception.Message)"
    throw
}

$candidates = @()
if ($response -and $response.PSObject.Properties.Name -contains 'value') {
    $candidates = @($response.value)
}

Write-StepResult -Level INFO -Message "Found $($candidates.Count) candidate trigger component(s) currently in active state."

if ($candidates.Count -eq 0) {
    Write-StepResult -Level PASS -Message "Nothing to disable. Exiting."
    return
}

foreach ($component in $candidates) {
    $name = [string]$component.name
    $id = [string]$component.botcomponentid
    $type = $component.componenttype
    $parent = [string]$component._parentbotid_value
    Write-StepResult -Level INFO -Message "  - $name (componenttype=$type, parentBot=$parent, id=$id)"
}

if ($ListOnly) {
    Write-Section "ListOnly mode — no changes made"
    Write-StepResult -Level PASS -Message "Re-run without -ListOnly (and without -WhatIf) to disable the listed components."
    return
}

Write-Section "Disabling trigger components"
$disabledCount = 0
$failedCount = 0
foreach ($component in $candidates) {
    $name = [string]$component.name
    $id = [string]$component.botcomponentid
    $target = "botcomponent '$name' ($id)"

    if (-not $PSCmdlet.ShouldProcess($target, 'Disable autonomous trigger (statecode=1, statuscode=2)')) {
        continue
    }

    try {
        $body = @{ statecode = 1; statuscode = 2 }
        Invoke-DataverseWebApiRequest -EnvironmentUrl $environmentUrl -AccessToken $accessToken -RelativeUri "botcomponents($id)" -Method PATCH -Body $body | Out-Null
        Write-StepResult -Level PASS -Message "Disabled $target."
        Write-Log -Level INFO -Message "Disabled $target."
        $disabledCount++
    }
    catch {
        Write-StepResult -Level WARN -Message ("Failed to disable {0}: {1}" -f $target, $_.Exception.Message)
        Write-Log -Level WARN -Message ("Failed to disable {0}: {1}" -f $target, $_.Exception.Message)
        $failedCount++
    }
}

Write-Section "Cleanup summary"
Write-StepResult -Level PASS -Message "Disabled: $disabledCount"
if ($failedCount -gt 0) {
    Write-StepResult -Level WARN -Message "Failed: $failedCount (see log for details)."
}
