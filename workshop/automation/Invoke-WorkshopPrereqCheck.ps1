[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [ValidateSet('StudentReady', 'FacilitatorDemo')]
    [string]$Mode = 'StudentReady'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Resolve-SharePointPnPLoginMode {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    if (Test-PlaceholderValue -Value $Value) {
        return 'OSLogin'
    }

    $normalizedValue = $Value.Trim()
    if ($normalizedValue -notin @('OSLogin', 'DeviceLogin', 'Interactive', 'CertificateThumbprint')) {
        throw "Config value 'SharePoint.PnPLoginMode' is not supported. Supported values: OSLogin, DeviceLogin, Interactive, CertificateThumbprint."
    }

    return $normalizedValue
}

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath

$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'
$rawEnvironmentUrl = [string]$config.EnvironmentUrl
if (Test-PlaceholderValue -Value $rawEnvironmentUrl) {
    if ($null -ne $config.EnvironmentBootstrap) {
        throw "Config value 'EnvironmentUrl' is not ready yet. Run Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment (or Invoke-WorkshopLabSetup.ps1 -CreateEnvironment) to create the facilitator environment and capture its URL before prerequisite validation."
    }

    throw "Config value 'EnvironmentUrl' is required."
}

$environmentUrl = Get-RequiredString -Value $rawEnvironmentUrl -Name 'EnvironmentUrl'
$siteUrl = Get-RequiredString -Value ([string]$config.SharePoint.SiteUrl) -Name 'SharePoint.SiteUrl'
$siteTitle = Get-RequiredString -Value ([string]$config.SharePoint.SiteTitle) -Name 'SharePoint.SiteTitle'
$siteAlias = Get-RequiredString -Value ([string]$config.SharePoint.SiteAlias) -Name 'SharePoint.SiteAlias'
$siteDescription = Get-RequiredString -Value ([string]$config.SharePoint.SiteDescription) -Name 'SharePoint.SiteDescription'
$sharePointPnPClientId = [string]$config.SharePoint.PnPClientId
if (Test-PlaceholderValue -Value $sharePointPnPClientId) {
    throw "Config value 'SharePoint.PnPClientId' is required for modern PnP sign-in. Register or reuse an Entra ID app, then set its application (client) ID before running lab setup."
}

$sharePointPnPClientId = Get-RequiredString -Value $sharePointPnPClientId -Name 'SharePoint.PnPClientId'
$sharePointPnPLoginMode = Resolve-SharePointPnPLoginMode -Value ([string]$config.SharePoint.PnPLoginMode)
$sharePointPnPCertificateThumbprint = [string]$config.SharePoint.PnPCertificateThumbprint

if ($sharePointPnPLoginMode -eq 'CertificateThumbprint') {
    if (Test-PlaceholderValue -Value $sharePointPnPCertificateThumbprint) {
        throw "Config value 'SharePoint.PnPCertificateThumbprint' is required when SharePoint.PnPLoginMode is CertificateThumbprint."
    }

    $sharePointPnPCertificateThumbprint = Get-RequiredString -Value $sharePointPnPCertificateThumbprint -Name 'SharePoint.PnPCertificateThumbprint'
}

Write-StepResult -Level PASS -Message "Loaded config for tenant '$tenantId' and environment '$environmentUrl'."
Write-StepResult -Level PASS -Message "Configured SharePoint site '$siteTitle' at '$siteUrl' with alias '$siteAlias'."
Write-StepResult -Level PASS -Message "Configured SharePoint PnP sign-in with login mode '$sharePointPnPLoginMode' and a client ID."
if ($sharePointPnPLoginMode -eq 'CertificateThumbprint') {
    Write-StepResult -Level PASS -Message "Configured SharePoint PnP certificate thumbprint '$sharePointPnPCertificateThumbprint'."
}

Write-Section "Checking local tooling"
Require-Module -Name 'PnP.PowerShell'
Write-StepResult -Level PASS -Message "PnP.PowerShell is installed."

if ($Mode -eq 'FacilitatorDemo' -or [bool]$config.Day2.ImportOperativeSolution) {
    Require-Command -Name 'pac'
    Write-StepResult -Level PASS -Message "Power Platform CLI (pac) is available."
}
else {
    if (Get-Command -Name 'pac' -ErrorAction SilentlyContinue) {
        Write-StepResult -Level PASS -Message "Power Platform CLI (pac) is available."
    }
    else {
        Write-StepResult -Level WARN -Message "Power Platform CLI (pac) is not installed. Install it before you attempt environment bootstrap or a facilitator demo import."
    }
}

Write-Section "Validating Day 1 sample data configuration"
$sampleDevices = @($config.Day1.SampleDevices)
if ($sampleDevices.Count -lt 4) {
    throw "Day1.SampleDevices must contain at least four sample devices so Labs 07-09 have data to work with."
}

$sampleTicketTitle = Get-RequiredString -Value ([string]$config.Day1.SampleTicket.Title) -Name 'Day1.SampleTicket.Title'
Get-RequiredString -Value ([string]$config.Day1.SampleTicket.Description) -Name 'Day1.SampleTicket.Description' | Out-Null
Get-RequiredString -Value ([string]$config.Day1.SampleTicket.Priority) -Name 'Day1.SampleTicket.Priority' | Out-Null

Write-StepResult -Level PASS -Message "Configured $($sampleDevices.Count) sample devices and sample ticket '$sampleTicketTitle'."

Write-Section "Validating Day 2 asset paths"
$operativeZipPath = Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.OperativeSolutionZipPath)
$jobRolesCsvPath = Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.JobRolesCsvPath)
$evaluationCriteriaCsvPath = Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.EvaluationCriteriaCsvPath)

$operativeZipPath = Assert-FileExists -Path $operativeZipPath -Label 'Operative solution package'
$jobRolesCsvPath = Assert-FileExists -Path $jobRolesCsvPath -Label 'Job roles CSV'
$evaluationCriteriaCsvPath = Assert-FileExists -Path $evaluationCriteriaCsvPath -Label 'Evaluation criteria CSV'

Write-StepResult -Level PASS -Message "Resolved Operative package path: $operativeZipPath"
Write-StepResult -Level PASS -Message "Resolved job roles CSV path: $jobRolesCsvPath"
Write-StepResult -Level PASS -Message "Resolved evaluation criteria CSV path: $evaluationCriteriaCsvPath"

Write-Section "Prerequisite summary"
Write-StepResult -Level INFO -Message "StudentReady mode preserves lab-owned build steps and only prepares shared prerequisites."
if ($Mode -eq 'FacilitatorDemo') {
    Write-StepResult -Level INFO -Message "FacilitatorDemo mode can be paired with Import-WorkshopOperativeAssets.ps1 when you want a separate demo environment pre-staged."
}
