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
$participantEmails = @($config.Identity.ParticipantEmails)
$rawEnvironmentUrl = [string]$config.EnvironmentUrl
$environmentUrlReady = $true
if (Test-PlaceholderValue -Value $rawEnvironmentUrl) {
    if ($Mode -eq 'FacilitatorDemo') {
        throw "Config value 'EnvironmentUrl' is not ready yet. Run Initialize-WorkshopPowerPlatformEnvironment.ps1 -CreateEnvironment (or Invoke-WorkshopLabSetup.ps1 -CreateEnvironment) to create the facilitator environment and capture its URL before prerequisite validation."
    }
    $environmentUrlReady = $false
    $environmentUrl = $rawEnvironmentUrl
}
else {
    $environmentUrl = Get-RequiredString -Value $rawEnvironmentUrl -Name 'EnvironmentUrl'
}
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
if (-not $environmentUrlReady) {
    Write-StepResult -Level WARN -Message "EnvironmentUrl still contains a placeholder value. Shared prerequisite validation can continue, but facilitator environment-specific steps are not ready yet."
}
Write-StepResult -Level PASS -Message "Configured SharePoint site '$siteTitle' at '$siteUrl' with alias '$siteAlias'."
Write-StepResult -Level PASS -Message "Configured SharePoint PnP sign-in with login mode '$sharePointPnPLoginMode' and a client ID."
if ($sharePointPnPLoginMode -eq 'CertificateThumbprint') {
    Write-StepResult -Level PASS -Message "Configured SharePoint PnP certificate thumbprint '$sharePointPnPCertificateThumbprint'."
}

# Validate Identity.ClientSecret availability (needed for per-student provisioning)
$resolvedClientSecret = Resolve-ConfiguredClientSecret -Config $config
if ($resolvedClientSecret.Value) {
    $secretSource = if ($resolvedClientSecret.Source -eq 'EnvironmentVariable') {
        "environment variable '$($resolvedClientSecret.EnvironmentVariableName)'"
    }
    else {
        'workshop-config.json'
    }
    Write-StepResult -Level PASS -Message "Identity.ClientSecret is available via $secretSource (supports app-only PowerApps admin auth such as DLP checks after one-time delegated Power Platform app registration)."
} elseif (-not [string]::IsNullOrWhiteSpace($resolvedClientSecret.EnvironmentVariableName)) {
    Write-StepResult -Level WARN -Message "Identity.ClientSecretEnvVar is set to '$($resolvedClientSecret.EnvironmentVariableName)' but the environment variable is not defined. App-only PowerApps admin auth will be skipped, and Copilot credit allocation may require manual PPAC allocation."
} else {
    Write-StepResult -Level WARN -Message "Neither Identity.ClientSecret nor Identity.ClientSecretEnvVar is configured. App-only PowerApps admin auth will be skipped, and Copilot credit allocation will be manual."
}
Write-StepResult -Level INFO -Message "This check can't verify Power Platform management-app registration. Before relying on app-only Power Platform admin calls, make sure the workshop app has the Power Apps Service delegated permission with admin consent and that a delegated Power Platform admin has run New-PowerAppManagementApp or pac admin application register once."

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

Write-Section "Validating student provisioning prerequisites"
if ($participantEmails.Count -eq 0) {
    Write-StepResult -Level INFO -Message 'No participant emails are configured, so per-student provisioning checks were skipped.'
}
else {
    Write-StepResult -Level PASS -Message "Configured $($participantEmails.Count) participant email(s) for per-student provisioning."

    if (Test-PlaceholderValue -Value $sharePointPnPCertificateThumbprint) {
        Write-StepResult -Level WARN -Message "SharePoint.PnPCertificateThumbprint is not configured. Per-student provisioning is not ready until bootstrap imports or creates a certificate and registers it on the workshop app."
    }
    else {
        Require-Module -Name 'Microsoft.Graph.Authentication'
        $studentProvisioningReadiness = Test-AppOnlyCertificateReadiness -TenantId $tenantId -ClientId $sharePointPnPClientId -Thumbprint $sharePointPnPCertificateThumbprint -SharePointAdminUrl ([string]$config.SharePoint.AdminUrl)
        if ($studentProvisioningReadiness.CertificateFound) {
            Write-StepResult -Level PASS -Message "Found the student-provisioning certificate '$($studentProvisioningReadiness.Certificate.Thumbprint)' in Cert:\CurrentUser\My."
        }
        else {
            Write-StepResult -Level WARN -Message "The configured student-provisioning certificate '$sharePointPnPCertificateThumbprint' was not found in Cert:\CurrentUser\My."
        }

        if ($studentProvisioningReadiness.CertificateExpired) {
            Write-StepResult -Level WARN -Message "The configured student-provisioning certificate expired on $($studentProvisioningReadiness.Certificate.NotAfter.ToUniversalTime().ToString('u'))."
        }

        if ($studentProvisioningReadiness.GraphConnected) {
            Write-StepResult -Level PASS -Message 'Certificate-based Microsoft Graph app-only auth succeeded for student provisioning.'
        }
        elseif ($studentProvisioningReadiness.CertificateFound -and -not $studentProvisioningReadiness.CertificateExpired) {
            Write-StepResult -Level WARN -Message 'Certificate-based Microsoft Graph app-only auth is not ready for student provisioning.'
        }

        if ($studentProvisioningReadiness.SharePointConnected) {
            Write-StepResult -Level PASS -Message 'Certificate-based SharePoint app-only auth succeeded for student provisioning.'
        }
        elseif ($studentProvisioningReadiness.CertificateFound -and -not $studentProvisioningReadiness.CertificateExpired) {
            Write-StepResult -Level WARN -Message 'Certificate-based SharePoint app-only auth is not ready for student provisioning.'
        }

        Write-StepResult -Level INFO -Message 'This check confirms SharePoint app-only connectivity, but some tenants still deny app-only site creation. When that happens, Invoke-StudentEnvironmentProvisioning.ps1 falls back to delegated PnP sign-in for the site-creation step.'

        foreach ($studentProvisioningError in $studentProvisioningReadiness.Errors) {
            Write-StepResult -Level WARN -Message $studentProvisioningError
        }
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
