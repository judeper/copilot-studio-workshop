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
    [switch]$ImportOperativeSolution
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

$shouldImportOperativeSolution = if ($PSBoundParameters.ContainsKey('ImportOperativeSolution')) {
    $ImportOperativeSolution.IsPresent
}
else {
    $Mode -eq 'FacilitatorDemo' -and [bool]$config.Day2.ImportOperativeSolution
}

if ($shouldImportOperativeSolution) {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Import-WorkshopOperativeAssets.ps1') -ConfigPath $ConfigPath -ImportSolution
}
else {
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Import-WorkshopOperativeAssets.ps1') -ConfigPath $ConfigPath
}

Write-Section "Recommended next steps"
Write-StepResult -Level INFO -Message "StudentReady mode prepares the shared prerequisites and intentionally leaves agent authoring, topic creation, flow building, MCP setup, Teams publishing, and evaluation for the student walkthrough."
Write-StepResult -Level INFO -Message "Use FacilitatorDemo mode only against a separate demo environment when you want Lab 13 pre-staged instead of student-authored."
if ($CreateEnvironment) {
    Write-StepResult -Level WARN -Message "Environment bootstrap does not grant Copilot Studio author permissions, maker access, or connector/DLP approvals. Validate those separately before delivery."
}
