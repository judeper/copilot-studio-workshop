<#
.SYNOPSIS
    Interactive bootstrap wizard for the Copilot Studio Workshop.
.DESCRIPTION
    Run this once on a vanilla Windows 11 machine. It detects and installs every
    missing dependency, creates and populates the config file interactively,
    downloads assets, validates prerequisites, and reports readiness.

    Two ways to run:
    1. From a cloned repo:  powershell -File .\workshop\automation\Invoke-WorkshopBootstrap.ps1
    2. From any machine:    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/judeper/copilot-studio-workshop/master/workshop/automation/Invoke-WorkshopBootstrap.ps1)))
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath,

    [Parameter()]
    [string]$RepoUrl = 'https://github.com/judeper/copilot-studio-workshop.git'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# ============================================================================
# Helpers (inline — cannot depend on Common.ps1 until repo is confirmed)
# ============================================================================

# Detect execution context: invoked via irm | iex (no $PSScriptRoot) vs file
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { $null }
$isRemoteInvocation = $null -eq $scriptDir

function Write-Banner {
    param([string]$Message)
    $line = '=' * 70
    Write-Host "`n$line" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "$line`n" -ForegroundColor Cyan
}

function Write-Status {
    param([string]$Label, [string]$Status, [string]$Color = 'Green')
    $icon = switch ($Color) { 'Green' { '[PASS]' }; 'Yellow' { '[WARN]' }; 'Red' { '[FAIL]' }; default { '[INFO]' } }
    Write-Host "$icon $Label — $Status" -ForegroundColor $Color
}

function Test-CommandAvailable {
    param([string]$Name)
    return $null -ne (Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Install-ViAwinget {
    param([string]$WingetId, [string]$DisplayName, [string]$FallbackUrl)

    if (-not (Test-CommandAvailable -Name 'winget')) {
        Write-Status -Label $DisplayName -Status "winget not available. Install manually from: $FallbackUrl" -Color 'Yellow'
        Write-Host "`nPress Enter after installing $DisplayName..." -ForegroundColor Yellow
        Read-Host
        return
    }

    Write-Host "Installing $DisplayName via winget..." -ForegroundColor Cyan
    & winget install --id $WingetId --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null

    # Refresh PATH for current session
    $machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $userPath = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = "$machinePath;$userPath"
}

function Prompt-Value {
    param(
        [string]$Prompt,
        [string]$Default = '',
        [switch]$Required
    )
    $displayPrompt = if ($Default) { "$Prompt [$Default]" } else { $Prompt }
    do {
        Write-Host "$displayPrompt`: " -ForegroundColor Yellow -NoNewline
        $value = Read-Host
        if ([string]::IsNullOrWhiteSpace($value) -and $Default) { $value = $Default }
        if ($Required -and [string]::IsNullOrWhiteSpace($value)) {
            Write-Host "  This value is required." -ForegroundColor Red
        }
    } while ($Required -and [string]::IsNullOrWhiteSpace($value))
    return $value.Trim()
}

function Prompt-YesNo {
    param([string]$Question, [bool]$Default = $true)
    $hint = if ($Default) { '[Y/n]' } else { '[y/N]' }
    Write-Host "$Question $hint`: " -ForegroundColor Yellow -NoNewline
    $answer = Read-Host
    if ([string]::IsNullOrWhiteSpace($answer)) { return $Default }
    return $answer.Trim().ToLowerInvariant() -in @('y', 'yes')
}

# ============================================================================
# Step 0: Repo check
# ============================================================================
Write-Banner 'Step 0: Repository Check'

$repoRoot = $null
$automationDir = $null

if (-not $isRemoteInvocation) {
    $commonPath = Join-Path -Path $scriptDir -ChildPath 'Common.ps1'
    if (Test-Path -LiteralPath $commonPath) {
        $automationDir = $scriptDir
        $repoRoot = Split-Path -Path $automationDir -Parent | Split-Path -Parent
        Write-Status -Label 'Repository' -Status "Found at $repoRoot" -Color 'Green'
    }
}

if ($null -eq $repoRoot) {
    # Repo not on disk — need to clone
    Write-Status -Label 'Repository' -Status 'Not found on disk — will clone' -Color 'Yellow'

    if (-not (Test-CommandAvailable -Name 'git')) {
        Write-Host "`ngit is required to clone the repository." -ForegroundColor Yellow
        Install-ViAwinget -WingetId 'Git.Git' -DisplayName 'Git' -FallbackUrl 'https://git-scm.com/download/win'

        if (-not (Test-CommandAvailable -Name 'git')) {
            throw 'git is still not available after install attempt. Install it manually and re-run.'
        }
    }

    $cloneTarget = Join-Path -Path (Get-Location) -ChildPath 'copilot-studio-workshop'
    if (Test-Path -LiteralPath (Join-Path -Path $cloneTarget -ChildPath 'workshop\automation\Common.ps1')) {
        Write-Status -Label 'Repository' -Status "Already cloned at $cloneTarget" -Color 'Green'
    } else {
        Write-Host "Cloning repository to $cloneTarget..." -ForegroundColor Cyan
        & git clone $RepoUrl $cloneTarget 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }
        Write-Status -Label 'Repository' -Status "Cloned to $cloneTarget" -Color 'Green'
    }

    $repoRoot = $cloneTarget
    $automationDir = Join-Path -Path $repoRoot -ChildPath 'workshop\automation'
}

$ConfigPath = Join-Path -Path $automationDir -ChildPath 'workshop-config.json'
$commonPath = Join-Path -Path $automationDir -ChildPath 'Common.ps1'

Set-Location -Path $repoRoot
Write-Host "Working directory: $repoRoot" -ForegroundColor Gray

. $commonPath

# ============================================================================
# Step 1: CLI Tools
# ============================================================================
Write-Banner 'Step 1: CLI Tools'

$tools = @(
    @{ Name = 'git';  WingetId = 'Git.Git';                DisplayName = 'Git';                   FallbackUrl = 'https://git-scm.com/download/win';     Required = $true  }
    @{ Name = 'pac';  WingetId = 'Microsoft.PowerAppsCLI';  DisplayName = 'Power Platform CLI';    FallbackUrl = 'https://aka.ms/PowerAppsCLI';          Required = $true  }
    @{ Name = 'node'; WingetId = 'OpenJS.NodeJS.LTS';       DisplayName = 'Node.js (for PDFs)';    FallbackUrl = 'https://nodejs.org';                   Required = $false }
)

foreach ($tool in $tools) {
    if (Test-CommandAvailable -Name $tool.Name) {
        $version = try { (& $tool.Name --version 2>&1 | Select-Object -First 1).ToString().Trim() } catch { 'installed' }
        Write-Status -Label $tool.DisplayName -Status $version -Color 'Green'
    } else {
        Write-Status -Label $tool.DisplayName -Status 'Not found' -Color $(if ($tool.Required) { 'Red' } else { 'Yellow' })
        if ($tool.Required -or (Prompt-YesNo -Question "Install $($tool.DisplayName)?")) {
            Install-ViAwinget -WingetId $tool.WingetId -DisplayName $tool.DisplayName -FallbackUrl $tool.FallbackUrl
        }

        if (Test-CommandAvailable -Name $tool.Name) {
            Write-Status -Label $tool.DisplayName -Status 'Installed successfully' -Color 'Green'
        } elseif ($tool.Required) {
            Write-Host "WARNING: $($tool.DisplayName) is required but still not found. Some steps may fail." -ForegroundColor Red
        }
    }
}

# ============================================================================
# Step 2: PowerShell Modules
# ============================================================================
Write-Banner 'Step 2: PowerShell Modules'

$modules = @(
    @{ Name = 'PnP.PowerShell';                                      Label = 'PnP.PowerShell (SharePoint)';         Required = $true  }
    @{ Name = 'Microsoft.Graph.Authentication';                       Label = 'Microsoft.Graph (Teams/Groups)';      Required = $true  }
    @{ Name = 'Microsoft.PowerApps.Administration.PowerShell';        Label = 'PowerApps Admin (DLP checks)';        Required = $false }
)

foreach ($mod in $modules) {
    if (Get-Module -ListAvailable -Name $mod.Name) {
        $ver = (Get-Module -ListAvailable -Name $mod.Name | Select-Object -First 1).Version.ToString()
        Write-Status -Label $mod.Label -Status "v$ver" -Color 'Green'
    } else {
        Write-Status -Label $mod.Label -Status 'Not found — installing...' -Color 'Yellow'
        try {
            Install-Module -Name $mod.Name -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Status -Label $mod.Label -Status 'Installed' -Color 'Green'
        }
        catch {
            if ($mod.Required) {
                Write-Status -Label $mod.Label -Status "Install failed: $_" -Color 'Red'
            } else {
                Write-Status -Label $mod.Label -Status "Install failed (optional): $_" -Color 'Yellow'
            }
        }
    }
}

# ============================================================================
# Step 3: Config File Setup
# ============================================================================
Write-Banner 'Step 3: Workshop Configuration'

$exampleConfigPath = Join-Path -Path $automationDir -ChildPath 'workshop-config.example.json'

if (Test-Path -LiteralPath $ConfigPath) {
    Write-Status -Label 'Config file' -Status 'Found existing workshop-config.json' -Color 'Green'
    if (-not (Prompt-YesNo -Question 'Use existing config? (No = start fresh)' -Default $true)) {
        Copy-Item -Path $exampleConfigPath -Destination $ConfigPath -Force
        Write-Status -Label 'Config file' -Status 'Reset from example template' -Color 'Yellow'
    }
} else {
    Copy-Item -Path $exampleConfigPath -Destination $ConfigPath -Force
    Write-Status -Label 'Config file' -Status 'Created from example template' -Color 'Green'
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json -Depth 100

# Tenant name (used to derive URLs)
Write-Host "`n--- Tenant Information ---" -ForegroundColor Cyan
$tenantName = Prompt-Value -Prompt 'Microsoft 365 tenant name (e.g. contoso)' -Required

# Try auto-detect TenantId from pac auth
$detectedTenantId = ''
if (Test-CommandAvailable -Name 'pac') {
    $pacAuthOutput = & pac auth list 2>&1 | ForEach-Object { $_.ToString() }
    $tenantMatch = $pacAuthOutput | Select-String -Pattern '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})' | Select-Object -First 1
    if ($tenantMatch) {
        $detectedTenantId = $tenantMatch.Matches[0].Value
    }
}

if ($detectedTenantId) {
    $tenantId = Prompt-Value -Prompt "TenantId (auto-detected from pac)" -Default $detectedTenantId -Required
} else {
    $tenantId = Prompt-Value -Prompt 'TenantId (GUID from Azure portal > Entra ID > Overview)' -Required
}
$config.TenantId = $tenantId

# Derive SharePoint URLs
$adminUrl = "https://$tenantName-admin.sharepoint.com"
$siteUrl = "https://$tenantName.sharepoint.com/sites/ContosoIT"

Write-Host "`n--- SharePoint Configuration ---" -ForegroundColor Cyan
$config.SharePoint.AdminUrl = Prompt-Value -Prompt 'SharePoint Admin URL' -Default $adminUrl -Required
$config.SharePoint.SiteUrl = Prompt-Value -Prompt 'SharePoint Site URL' -Default $siteUrl -Required
$config.SharePoint.PnPClientId = Prompt-Value -Prompt 'Entra App Client ID (for PnP auth)' -Default ([string]$config.SharePoint.PnPClientId) -Required

# Auth mode
Write-Host "`n--- Authentication Mode ---" -ForegroundColor Cyan
Write-Host "  1. DeviceLogin (default — interactive device code flow)" -ForegroundColor White
Write-Host "  2. Interactive (browser popup)" -ForegroundColor White
Write-Host "  3. CertificateThumbprint (app-only — requires .pfx in cert store)" -ForegroundColor White
$authChoice = Prompt-Value -Prompt 'Choose auth mode (1/2/3)' -Default '1'
$config.SharePoint.PnPLoginMode = switch ($authChoice) {
    '2' { 'Interactive' }
    '3' { 'CertificateThumbprint' }
    default { 'DeviceLogin' }
}

if ($config.SharePoint.PnPLoginMode -eq 'CertificateThumbprint') {
    $config.SharePoint.PnPCertificateThumbprint = Prompt-Value -Prompt 'Certificate thumbprint' -Required

    # Check if .pfx exists in repo and offer to import
    $pfxFiles = Get-ChildItem -Path $repoRoot -Filter '*.pfx' -ErrorAction SilentlyContinue
    if ($pfxFiles) {
        Write-Host "`nFound .pfx file(s): $($pfxFiles.Name -join ', ')" -ForegroundColor Cyan
        if (Prompt-YesNo -Question 'Import the first .pfx into your certificate store?') {
            Import-PfxCertificate -FilePath $pfxFiles[0].FullName -CertStoreLocation Cert:\CurrentUser\My | Out-Null
            Write-Status -Label 'Certificate' -Status "Imported $($pfxFiles[0].Name)" -Color 'Green'
        }
    }
}

# Environment bootstrap
Write-Host "`n--- Environment Bootstrap ---" -ForegroundColor Cyan
$domainDefault = "$tenantName-workshop"
$config.EnvironmentBootstrap.DomainName = Prompt-Value -Prompt 'Environment domain prefix' -Default $domainDefault

# Student provisioning
Write-Host "`n--- Student Provisioning (Optional) ---" -ForegroundColor Cyan
if (Prompt-YesNo -Question 'Provision per-student environments?' -Default $false) {
    Write-Host "Enter student emails (one per line, empty line to finish):" -ForegroundColor Yellow
    $emails = [System.Collections.ArrayList]@()
    while ($true) {
        $email = Read-Host '  Email'
        if ([string]::IsNullOrWhiteSpace($email)) { break }
        [void]$emails.Add($email.Trim())
    }
    if ($emails.Count -gt 0) {
        $config.Identity.ParticipantEmails = @($emails)
        Write-Status -Label 'Students' -Status "$($emails.Count) email(s) configured" -Color 'Green'
    }
}

# Save config
$config | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $ConfigPath -Encoding UTF8
Write-Status -Label 'Config' -Status "Saved to $ConfigPath" -Color 'Green'

# ============================================================================
# Step 4: pac CLI Authentication
# ============================================================================
Write-Banner 'Step 4: Power Platform CLI Authentication'

if (Test-CommandAvailable -Name 'pac') {
    $pacAuthCheck = & pac auth list 2>&1 | ForEach-Object { $_.ToString() }
    $hasProfile = $pacAuthCheck | Select-String -Pattern '\*' -SimpleMatch
    if ($hasProfile) {
        Write-Status -Label 'pac auth' -Status 'Active profile found' -Color 'Green'
        $pacAuthCheck | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } else {
        Write-Status -Label 'pac auth' -Status 'No active profile — launching interactive sign-in' -Color 'Yellow'
        Write-Host "`nSign in with a Power Platform admin account..." -ForegroundColor Yellow
        & pac auth create 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        if ($LASTEXITCODE -eq 0) {
            Write-Status -Label 'pac auth' -Status 'Authenticated successfully' -Color 'Green'
        } else {
            Write-Status -Label 'pac auth' -Status 'Authentication may have failed — verify manually' -Color 'Yellow'
        }
    }
} else {
    Write-Status -Label 'pac auth' -Status 'pac CLI not available — skipping' -Color 'Red'
}

# ============================================================================
# Step 5: Entra App Validation
# ============================================================================
Write-Banner 'Step 5: Entra App Permissions Check'

$clientId = [string]$config.SharePoint.PnPClientId
if (-not [string]::IsNullOrWhiteSpace($clientId) -and $clientId -notmatch '^<') {
    Write-Host "Entra App Client ID: $clientId" -ForegroundColor White

    $requiredPerms = @(
        'Sites.FullControl.All (SharePoint — application)',
        'Group.ReadWrite.All (Graph — application)',
        'Team.Create (Graph — application)',
        'User.Read.All (Graph — application)'
    )

    Write-Host "`nRequired API permissions for full provisioning:" -ForegroundColor Yellow
    foreach ($perm in $requiredPerms) {
        Write-Host "  [ ] $perm" -ForegroundColor White
    }

    Write-Host "`nVerify at: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$clientId" -ForegroundColor Cyan
    Write-Host "Also ensure admin consent is granted for all permissions above.`n" -ForegroundColor Yellow

    # Test PnP connectivity if in CertificateThumbprint mode
    if ($config.SharePoint.PnPLoginMode -eq 'CertificateThumbprint') {
        try {
            Import-Module PnP.PowerShell -ErrorAction Stop
            Connect-PnPOnline -Url $config.SharePoint.AdminUrl -ClientId $clientId -Tenant $tenantId -Thumbprint $config.SharePoint.PnPCertificateThumbprint -ErrorAction Stop
            Write-Status -Label 'PnP connectivity' -Status 'Connected to SharePoint admin successfully' -Color 'Green'
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
        }
        catch {
            Write-Status -Label 'PnP connectivity' -Status "Failed: $_" -Color 'Red'
            Write-Host "  Verify the certificate is imported and the Entra app has Sites.FullControl.All." -ForegroundColor Yellow
        }
    }
} else {
    Write-Status -Label 'Entra App' -Status 'PnPClientId not configured — SharePoint automation will use interactive auth' -Color 'Yellow'
}

# ============================================================================
# Step 6: Download Day 2 Assets
# ============================================================================
Write-Banner 'Step 6: Download Workshop Assets'

$assetScript = Join-Path -Path $automationDir -ChildPath 'Get-WorkshopDay2Assets.ps1'
if (Test-Path -LiteralPath $assetScript) {
    Write-Host 'Downloading Day 2 assets from GitHub...' -ForegroundColor Cyan
    try {
        & $assetScript
        Write-Status -Label 'Day 2 assets' -Status 'Download complete' -Color 'Green'
    }
    catch {
        Write-Status -Label 'Day 2 assets' -Status "Download failed: $_" -Color 'Red'
        Write-Host '  You can retry later with: powershell -File .\workshop\automation\Get-WorkshopDay2Assets.ps1' -ForegroundColor Yellow
    }
} else {
    Write-Status -Label 'Day 2 assets' -Status 'Get-WorkshopDay2Assets.ps1 not found' -Color 'Red'
}

# ============================================================================
# Step 7: Prerequisites Validation
# ============================================================================
Write-Banner 'Step 7: Prerequisites Validation'

$prereqScript = Join-Path -Path $automationDir -ChildPath 'Invoke-WorkshopPrereqCheck.ps1'
if (Test-Path -LiteralPath $prereqScript) {
    try {
        & $prereqScript -ConfigPath $ConfigPath
        Write-Status -Label 'Prerequisites' -Status 'All checks passed' -Color 'Green'
    }
    catch {
        Write-Status -Label 'Prerequisites' -Status "Validation failed: $_" -Color 'Red'
    }
} else {
    Write-Status -Label 'Prerequisites' -Status 'Invoke-WorkshopPrereqCheck.ps1 not found' -Color 'Red'
}

# ============================================================================
# Step 8: Readiness Dashboard
# ============================================================================
Write-Banner 'Step 8: Readiness Dashboard'

$dashboard = @(
    @{ Label = 'git';                    Check = { Test-CommandAvailable -Name 'git' } }
    @{ Label = 'pac CLI';                Check = { Test-CommandAvailable -Name 'pac' } }
    @{ Label = 'Node.js (optional)';     Check = { Test-CommandAvailable -Name 'node' } }
    @{ Label = 'PnP.PowerShell';         Check = { $null -ne (Get-Module -ListAvailable -Name 'PnP.PowerShell') } }
    @{ Label = 'Microsoft.Graph';        Check = { $null -ne (Get-Module -ListAvailable -Name 'Microsoft.Graph.Authentication') } }
    @{ Label = 'Config file';            Check = { Test-Path -LiteralPath $ConfigPath } }
    @{ Label = 'TenantId configured';    Check = { -not [string]::IsNullOrWhiteSpace($config.TenantId) -and $config.TenantId -notmatch '^<' } }
    @{ Label = 'SharePoint URLs set';    Check = { $config.SharePoint.SiteUrl -notmatch '^<' -and $config.SharePoint.AdminUrl -notmatch '^<' } }
    @{ Label = 'PnPClientId set';        Check = { -not [string]::IsNullOrWhiteSpace([string]$config.SharePoint.PnPClientId) -and [string]$config.SharePoint.PnPClientId -notmatch '^<' } }
    @{ Label = 'pac auth profile';       Check = { (Test-CommandAvailable -Name 'pac') -and ((& pac auth list 2>&1 | ForEach-Object { $_.ToString() }) | Select-String -Pattern '\*' -SimpleMatch) } }
    @{
        Label = 'Day 2 assets'
        Check = {
            $assetsDir = Join-Path -Path $automationDir -ChildPath '..\assets'
            (Test-Path (Join-Path $assetsDir 'Operative_1_0_0_0.zip')) -and
            (Test-Path (Join-Path $assetsDir 'job-roles.csv')) -and
            (Test-Path (Join-Path $assetsDir 'evaluation-criteria.csv'))
        }
    }
)

$allGreen = $true
foreach ($item in $dashboard) {
    $pass = try { & $item.Check } catch { $false }
    if ($pass) {
        Write-Host "  [PASS] $($item.Label)" -ForegroundColor Green
    } else {
        Write-Host "  [----] $($item.Label)" -ForegroundColor Yellow
        $allGreen = $false
    }
}

Write-Host ''
if ($allGreen) {
    Write-Host '  All checks passed! You are ready to proceed.' -ForegroundColor Green
} else {
    Write-Host '  Some items need attention (see above). Fix them and re-run the wizard.' -ForegroundColor Yellow
}

Write-Host "`n--- Next Steps ---" -ForegroundColor Cyan
Write-Host '  1. Pre-stage shared Day 1 site:' -ForegroundColor White
Write-Host '     powershell -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady' -ForegroundColor Gray
Write-Host ''
Write-Host '  2. Optional: Batch-provision per-student environments:' -ForegroundColor White
Write-Host '     powershell -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1' -ForegroundColor Gray
Write-Host ''
Write-Host '  3. Post-workshop cleanup:' -ForegroundColor White
Write-Host '     powershell -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete' -ForegroundColor Gray
Write-Host ''
