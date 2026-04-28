[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [ValidateSet('StudentReady', 'FacilitatorDemo')]
    [string]$Mode = 'StudentReady',

    [Parameter()]
    [switch]$ValidateOnly,

    [Parameter()]
    [switch]$CreateEnvironment,

    [Parameter()]
    [switch]$ImportEnterpriseSolution
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

Write-Section "Starting workshop lab setup"
Write-StepResult -Level INFO -Message "Mode: $Mode"

if ($CreateEnvironment) {
    Write-StepResult -Level INFO -Message "CreateEnvironment will only bootstrap a facilitator-owned workshop environment and still leaves student lab work for the walkthrough."

    $environmentBootstrapParameters = @{
        ConfigPath = $ConfigPath
    }

    if (-not $ValidateOnly) {
        $environmentBootstrapParameters.CreateEnvironment = $true
        $environmentBootstrapParameters.UpdateConfig = $true
    }

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-WorkshopPowerPlatformEnvironment.ps1') @environmentBootstrapParameters
}

$config = Get-WorkshopConfig -Path $ConfigPath

if ($ValidateOnly -and $CreateEnvironment -and (Test-PlaceholderValue -Value ([string]$config.EnvironmentUrl))) {
    Write-Section "Validation-only run complete"
    Write-StepResult -Level INFO -Message "Environment bootstrap prerequisites were validated, but EnvironmentUrl is still unresolved because -ValidateOnly does not create or capture the environment."
    return
}

& (Join-Path -Path $PSScriptRoot -ChildPath 'Invoke-WorkshopPrereqCheck.ps1') -ConfigPath $ConfigPath -Mode $Mode

if ($ValidateOnly) {
    Write-Section "Validation-only run complete"
    Write-StepResult -Level INFO -Message "No changes were made because -ValidateOnly was supplied."
    return
}

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-WorkshopSharePoint.ps1') -ConfigPath $ConfigPath

$shouldImportEnterpriseSolution = if ($PSBoundParameters.ContainsKey('ImportEnterpriseSolution')) {
    $ImportEnterpriseSolution.IsPresent
}
else {
    $Mode -eq 'FacilitatorDemo' -and [bool]$config.Day2.ImportEnterpriseSolution
}

if ($shouldImportEnterpriseSolution) {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Import-WorkshopEnterpriseAssets.ps1') -ConfigPath $ConfigPath -ImportSolution
}
else {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Import-WorkshopEnterpriseAssets.ps1') -ConfigPath $ConfigPath
}

Write-Section "Recommended next steps"
Write-StepResult -Level INFO -Message "StudentReady mode prepares the shared prerequisites and intentionally leaves agent authoring, topic creation, flow building, MCP setup, Teams publishing, and evaluation for the student walkthrough."
Write-StepResult -Level INFO -Message "Use FacilitatorDemo mode only against a separate demo environment when you want Lab 13 pre-staged instead of student-authored."

if ($Mode -eq 'FacilitatorDemo') {
    Write-Section "FacilitatorDemo readiness"
    if ($shouldImportEnterpriseSolution) {
        Write-StepResult -Level WARN -Message 'Environment status: SOLUTION-ONLY. The WoodgroveLending solution was imported, but Lab 13 base data is NOT yet loaded. Run Import-WorkshopEnterpriseAssets.ps1 -ImportBaseData against this same environment to reach DEMO-READY.'
    }
    else {
        Write-StepResult -Level WARN -Message 'Environment status: NOT DEMO-READY. Solution import was skipped (Day2.ImportEnterpriseSolution=false or -ImportEnterpriseSolution:$false). Run Import-WorkshopEnterpriseAssets.ps1 -ImportSolution -ImportBaseData against this environment to reach DEMO-READY.'
    }
}
if ($CreateEnvironment) {
    Write-StepResult -Level WARN -Message "Environment bootstrap does not grant Copilot Studio author permissions, maker access, or connector/DLP approvals. Validate those separately before delivery."
}
