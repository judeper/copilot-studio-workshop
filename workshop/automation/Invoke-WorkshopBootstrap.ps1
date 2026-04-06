<#
.SYNOPSIS
    Interactive bootstrap wizard for the Copilot Studio Workshop.
.DESCRIPTION
    Run this once on a vanilla Windows 11 machine. It detects and installs every
    missing dependency, creates and populates the config file interactively,
    downloads assets, runs prerequisite checks, and reports shared setup readiness signals.

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
# PS 7 requirement -- install and re-launch if running in Windows PowerShell 5.1
# ============================================================================
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host 'PowerShell 7 is required. Checking...' -ForegroundColor Yellow
    $pwshPath = Get-Command -Name 'pwsh' -ErrorAction SilentlyContinue
    if (-not $pwshPath) {
        Write-Host 'Installing PowerShell 7 via winget...' -ForegroundColor Cyan
        $hasWinget = $null -ne (Get-Command -Name 'winget' -ErrorAction SilentlyContinue)
        if ($hasWinget) {
            & winget install --id Microsoft.PowerShell --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  winget install failed (exit code $LASTEXITCODE). Trying manual path..." -ForegroundColor Yellow
            }
            # Refresh PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
            $pwshPath = Get-Command -Name 'pwsh' -ErrorAction SilentlyContinue
        }
        if (-not $pwshPath) {
            Write-Host '' -ForegroundColor Red
            Write-Host '  PowerShell 7 could not be installed automatically.' -ForegroundColor Red
            Write-Host '  Install from: https://aka.ms/powershell' -ForegroundColor Yellow
            Write-Host '  After installing, re-run: pwsh -File Bootstrap.ps1' -ForegroundColor Yellow
            return
        }
    }
    Write-Host 'Re-launching in PowerShell 7...' -ForegroundColor Green
    & pwsh -File $MyInvocation.MyCommand.Path @PSBoundParameters
    return
}

# ============================================================================
# Helpers (inline -- cannot depend on Common.ps1 until repo is confirmed)
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
    Write-Host "$icon $Label -- $Status" -ForegroundColor $Color
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
    if ($LASTEXITCODE -ne 0) {
        Write-Status -Label $DisplayName -Status "winget install may have failed (exit code $LASTEXITCODE)" -Color 'Yellow'
    }

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
    # Repo not on disk -- need to clone
    Write-Status -Label 'Repository' -Status 'Not found on disk -- will clone' -Color 'Yellow'

    if (-not (Test-CommandAvailable -Name 'git')) {
        Write-Host "`ngit is required to clone the repository." -ForegroundColor Yellow
        Install-ViAwinget -WingetId 'Git.Git' -DisplayName 'Git' -FallbackUrl 'https://git-scm.com/download/win'

        if (-not (Test-CommandAvailable -Name 'git')) {
            throw 'git is still not available after install attempt. Install it manually and re-run.'
        }
    }

    # Determine clone target -- avoid nesting if already in a workshop-named directory
    $currentDir = (Get-Location).Path
    $currentDirName = Split-Path -Path $currentDir -Leaf

    if ($currentDirName -eq 'copilot-studio-workshop') {
        # Already in a folder named copilot-studio-workshop -- clone here directly
        $cloneTarget = $currentDir
        if (-not (Test-Path -LiteralPath (Join-Path -Path $cloneTarget -ChildPath '.git'))) {
            # Empty folder with the right name -- clone into current dir
            Write-Host "Cloning repository into current directory ($cloneTarget)..." -ForegroundColor Cyan
            & git clone $RepoUrl . 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }
        }
    } else {
        $cloneTarget = Join-Path -Path $currentDir -ChildPath 'copilot-studio-workshop'
        if (Test-Path -LiteralPath (Join-Path -Path $cloneTarget -ChildPath 'workshop\automation\Common.ps1')) {
            Write-Status -Label 'Repository' -Status "Already cloned at $cloneTarget" -Color 'Green'
        } else {
            Write-Host "Cloning repository to $cloneTarget..." -ForegroundColor Cyan
            & git clone $RepoUrl $cloneTarget 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) { throw 'git clone failed.' }
        }
    }

    Write-Status -Label 'Repository' -Status "Ready at $cloneTarget" -Color 'Green'
    $repoRoot = $cloneTarget
    $automationDir = Join-Path -Path $repoRoot -ChildPath 'workshop\automation'
}

$ConfigPath = Join-Path -Path $automationDir -ChildPath 'workshop-config.json'
$commonPath = Join-Path -Path $automationDir -ChildPath 'Common.ps1'

if (-not (Test-Path -LiteralPath $commonPath)) {
    throw "Common.ps1 not found at $commonPath. The repository may be incomplete -- try deleting the folder and re-running this script."
}

Set-Location -Path $repoRoot -ErrorAction Stop
Write-Host "Working directory: $repoRoot" -ForegroundColor Gray

. $commonPath

$script:WorkshopGraphAdminScopes = @(
    'Application.ReadWrite.All'
    'AppRoleAssignment.ReadWrite.All'
    'DelegatedPermissionGrant.ReadWrite.All'
    'Application.Read.All'
)

function Connect-WorkshopGraphAdminSession {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter()]
        [string[]]$RequiredScopes = $script:WorkshopGraphAdminScopes
    )

    $graphContext = Get-MgContext -ErrorAction SilentlyContinue
    if ($graphContext -and $graphContext.TenantId -eq $TenantId) {
        $grantedScopes = @($graphContext.Scopes)
        $missingScopes = $RequiredScopes | Where-Object { $_ -notin $grantedScopes }
        if ($missingScopes.Count -eq 0) {
            return
        }
    }

    Write-Host "`nSign in with an admin account to continue..." -ForegroundColor Yellow
    Write-Host "  A device code will be shown in the terminal if a browser popup is not available." -ForegroundColor Yellow
    Disconnect-MgGraph -ErrorAction SilentlyContinue
    Connect-MgGraph -TenantId $TenantId -Scopes $RequiredScopes -UseDeviceCode -ContextScope Process -NoWelcome
}

function Get-WorkshopApplicationRegistration {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter()]
        [string[]]$Select = @('id', 'appId', 'displayName')
    )

    $selectClause = [string]::Join(',', $Select)
    return Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/applications(appId='$ClientId')?`$select=$selectClause"
}

function Ensure-WorkshopAppCertificateCredential {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate,

        [Parameter()]
        [string]$DisplayName = 'Workshop Provisioning Certificate'
    )

    $app = Get-WorkshopApplicationRegistration -ClientId $ClientId -Select @('id', 'appId', 'displayName', 'keyCredentials')
    $existingKeyCredentials = @($app.keyCredentials)
    $thumbprintBase64 = [Convert]::ToBase64String($Certificate.GetCertHash())
    $matchingKey = $existingKeyCredentials | Where-Object { [string]$_.customKeyIdentifier -eq $thumbprintBase64 } | Select-Object -First 1
    if ($matchingKey) {
        return [pscustomobject]@{
            Added = $false
            AppId = $app.id
        }
    }

    $preservedKeyCredentials = foreach ($existingKey in $existingKeyCredentials) {
        if ([string]::IsNullOrWhiteSpace([string]$existingKey.key)) {
            throw "Existing certificate credential '$($existingKey.displayName)' is missing key material in the Graph response; refusing to overwrite it."
        }

        @{
            customKeyIdentifier = $existingKey.customKeyIdentifier
            displayName         = $existingKey.displayName
            endDateTime         = ([DateTimeOffset]$existingKey.endDateTime).ToUniversalTime().ToString('o')
            key                 = $existingKey.key
            keyId               = [string]$existingKey.keyId
            startDateTime       = ([DateTimeOffset]$existingKey.startDateTime).ToUniversalTime().ToString('o')
            type                = $existingKey.type
            usage               = $existingKey.usage
        }
    }

    $newKeyCredential = @{
        customKeyIdentifier = $thumbprintBase64
        displayName         = $DisplayName
        endDateTime         = $Certificate.NotAfter.ToUniversalTime().ToString('o')
        key                 = [Convert]::ToBase64String($Certificate.RawData)
        keyId               = ([Guid]::NewGuid()).ToString()
        startDateTime       = $Certificate.NotBefore.ToUniversalTime().ToString('o')
        type                = 'AsymmetricX509Cert'
        usage               = 'Verify'
    }

    $keyCredentialsToPersist = @()
    $keyCredentialsToPersist += @($preservedKeyCredentials)
    $keyCredentialsToPersist += $newKeyCredential

    $patchBody = @{
        keyCredentials = $keyCredentialsToPersist
    } | ConvertTo-Json -Depth 10

    Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/applications/$($app.id)" -Body $patchBody -ContentType 'application/json' | Out-Null
    return [pscustomobject]@{
        Added = $true
        AppId = $app.id
    }
}

function New-WorkshopAppClientSecret {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter()]
        [string]$DisplayName = 'Copilot Studio Workshop Provisioning Secret',

        [Parameter()]
        [int]$ValidityMonths = 12
    )

    $app = Get-WorkshopApplicationRegistration -ClientId $ClientId -Select @('id', 'appId', 'displayName')
    $body = @{
        passwordCredential = @{
            displayName = $DisplayName
            endDateTime = (Get-Date).AddMonths($ValidityMonths).ToUniversalTime().ToString('o')
        }
    } | ConvertTo-Json -Depth 5

    $response = Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/applications/$($app.id)/addPassword" -Body $body -ContentType 'application/json'
    if ([string]::IsNullOrWhiteSpace([string]$response.secretText)) {
        throw 'Microsoft Graph did not return the generated client secret.'
    }

    return [pscustomobject]@{
        SecretText  = [string]$response.secretText
        EndDateTime = [DateTimeOffset]$response.endDateTime
    }
}

function Import-WorkshopPfxCertificateFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    try {
        return Import-PfxCertificate -FilePath $FilePath -CertStoreLocation Cert:\CurrentUser\My -ErrorAction Stop
    }
    catch {
        Write-Status -Label 'Certificate' -Status "Initial import failed: $($_.Exception.Message)" -Color 'Yellow'
        Write-Host "  If the .pfx is password-protected, enter the password now." -ForegroundColor Yellow
        $password = Read-Host '  PFX password' -AsSecureString
        return Import-PfxCertificate -FilePath $FilePath -CertStoreLocation Cert:\CurrentUser\My -Password $password -ErrorAction Stop
    }
}

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
            throw "$($tool.DisplayName) is required but could not be installed. Install it manually from $($tool.FallbackUrl) and re-run this script."
        }
    }
}

# ============================================================================
# Step 2: PowerShell Modules
# ============================================================================
Write-Banner 'Step 2: PowerShell Modules'

# Ensure PSGallery is trusted (prevents interactive prompts on fresh PS 7 installs)
$psGallery = Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue
if ($psGallery -and $psGallery.InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Write-Status -Label 'PSGallery' -Status 'Set to Trusted' -Color 'Green'
}

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
        Write-Status -Label $mod.Label -Status 'Not found -- installing...' -Color 'Yellow'
        try {
            Install-Module -Name $mod.Name -Scope CurrentUser -Force -AllowClobber -AcceptLicense -ErrorAction Stop
            Write-Status -Label $mod.Label -Status 'Installed' -Color 'Green'
        }
        catch {
            if ($mod.Required) {
                throw "Required module $($mod.Name) could not be installed: $_"
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
if (-not (Test-Path -LiteralPath $exampleConfigPath)) {
    throw "Example config not found at $exampleConfigPath. The repository may be incomplete."
}

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
$tenantName = Prompt-Value -Prompt 'Microsoft 365 tenant name (e.g. woodgrove)' -Required

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

# Derive SharePoint URLs from tenant name
$adminUrl = "https://$tenantName-admin.sharepoint.com"
$siteUrl = "https://$tenantName.sharepoint.com/sites/WoodgroveBank"

Write-Host "`n--- SharePoint Configuration (auto-derived from tenant name) ---" -ForegroundColor Cyan
Write-Host "  Admin URL:  $adminUrl" -ForegroundColor White
Write-Host "  Site URL:   $siteUrl  (Woodgrove Bank workshop site)" -ForegroundColor White
$config.SharePoint.AdminUrl = $adminUrl
$config.SharePoint.SiteUrl = $siteUrl

# Entra App registration
Write-Host "`n--- Entra App Registration ---" -ForegroundColor Cyan
$existingClientId = [string]$config.SharePoint.PnPClientId
if (-not [string]::IsNullOrWhiteSpace($existingClientId) -and $existingClientId -notmatch '^<') {
    Write-Status -Label 'Entra App' -Status "Existing Client ID: $existingClientId" -Color 'Green'
    if (-not (Prompt-YesNo -Question 'Use this existing app?' -Default $true)) {
        $existingClientId = ''
    }
}

if ([string]::IsNullOrWhiteSpace($existingClientId) -or $existingClientId -match '^<') {
    Write-Host "`nCreating a new Entra app registration for the workshop..." -ForegroundColor Cyan
    Write-Host "  This requires Global Administrator or Application Administrator role." -ForegroundColor Yellow

    try {
        # Ensure Graph connection with the scopes needed to create apps, inspect resource permissions,
        # and create delegated permission grants.
        Connect-WorkshopGraphAdminSession -TenantId $tenantId

        $appDisplayName = "Copilot Studio Workshop - $tenantName"
        $spOnlineAppId = '00000003-0000-0ff1-ce00-000000000000'  # SharePoint Online
        $graphAppId = '00000003-0000-0000-c000-000000000000'     # Microsoft Graph

        $resourceServicePrincipals = @{}
        function Get-ResourceServicePrincipal {
            param(
                [Parameter(Mandatory = $true)]
                [string]$ResourceAppId
            )

            if (-not $resourceServicePrincipals.ContainsKey($ResourceAppId)) {
                $response = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$ResourceAppId'&`$select=id,displayName,appRoles,oauth2PermissionScopes"
                $servicePrincipal = $response.value | Select-Object -First 1
                if ($null -eq $servicePrincipal) {
                    throw "Could not load service principal metadata for resource app '$ResourceAppId'."
                }

                $resourceServicePrincipals[$ResourceAppId] = $servicePrincipal
            }

            return $resourceServicePrincipals[$ResourceAppId]
        }

        function Resolve-ResourcePermissionId {
            param(
                [Parameter(Mandatory = $true)]
                [string]$ResourceAppId,

                [Parameter(Mandatory = $true)]
                [ValidateSet('Role', 'Scope')]
                [string]$PermissionType,

                [Parameter(Mandatory = $true)]
                [string]$PermissionValue
            )

            $resourceServicePrincipal = Get-ResourceServicePrincipal -ResourceAppId $ResourceAppId
            $permissionCollection = if ($PermissionType -eq 'Role') { $resourceServicePrincipal.appRoles } else { $resourceServicePrincipal.oauth2PermissionScopes }
            $permission = $permissionCollection | Where-Object { $_.value -eq $PermissionValue -and ($null -eq $_.isEnabled -or $_.isEnabled) } | Select-Object -First 1
            if ($null -eq $permission) {
                throw "Could not resolve $PermissionType '$PermissionValue' on resource '$($resourceServicePrincipal.displayName)' ($ResourceAppId)."
            }

            return [string]$permission.id
        }

        function Ensure-ServicePrincipalAppRoleAssignments {
            param(
                [Parameter(Mandatory = $true)]
                [string]$ClientServicePrincipalId,

                [Parameter(Mandatory = $true)]
                [string]$ResourceAppId,

                [Parameter(Mandatory = $true)]
                [string[]]$RoleValues
            )

            $resourceServicePrincipal = Get-ResourceServicePrincipal -ResourceAppId $ResourceAppId
            $resourceServicePrincipalId = [string]$resourceServicePrincipal.id
            $existingAssignments = @((Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$ClientServicePrincipalId/appRoleAssignments?`$select=id,appRoleId,resourceId" -ErrorAction Stop).value)
            $messages = [System.Collections.ArrayList]@()

            foreach ($roleValue in $RoleValues) {
                $role = $resourceServicePrincipal.appRoles |
                    Where-Object {
                        $_.value -eq $roleValue -and
                        ($null -eq $_.isEnabled -or $_.isEnabled) -and
                        ($_.allowedMemberTypes -contains 'Application')
                    } |
                    Select-Object -First 1

                if ($null -eq $role) {
                    throw "Could not resolve application role '$roleValue' on resource '$($resourceServicePrincipal.displayName)' ($ResourceAppId)."
                }

                $existingAssignment = $existingAssignments |
                    Where-Object {
                        [string]$_.resourceId -eq $resourceServicePrincipalId -and
                        [string]$_.appRoleId -eq [string]$role.id
                    } |
                    Select-Object -First 1

                if ($null -ne $existingAssignment) {
                    [void]$messages.Add("$roleValue verified")
                    continue
                }

                $body = @{
                    principalId = $ClientServicePrincipalId
                    resourceId  = $resourceServicePrincipalId
                    appRoleId   = [string]$role.id
                } | ConvertTo-Json

                Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/servicePrincipals/$ClientServicePrincipalId/appRoleAssignments" -Body $body -ContentType 'application/json' -ErrorAction Stop | Out-Null
                [void]$messages.Add("$roleValue granted")

                $existingAssignments += [pscustomobject]@{
                    resourceId = $resourceServicePrincipalId
                    appRoleId  = [string]$role.id
                }
            }

            return [pscustomobject]@{
                ResourceDisplayName = [string]$resourceServicePrincipal.displayName
                StatusMessage       = [string]::Join('; ', @($messages))
            }
        }

        $requiredGraphAppRoleValues = @(
            'Group.ReadWrite.All'
            'Directory.Read.All'
            'User.Read.All'
            'Team.Create'
        )

        $requiredResourceAccess = @(
            @{
                resourceAppId  = $graphAppId
                resourceAccess = @(
                    # Application permissions (for batch provisioning with certificate)
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Role' -PermissionValue 'Group.ReadWrite.All'); type = 'Role' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Role' -PermissionValue 'Directory.Read.All'); type = 'Role' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Role' -PermissionValue 'User.Read.All'); type = 'Role' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Role' -PermissionValue 'Team.Create'); type = 'Role' }
                    # Delegated permissions (for interactive/browser auth)
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Scope' -PermissionValue 'Group.ReadWrite.All'); type = 'Scope' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Scope' -PermissionValue 'User.Read.All'); type = 'Scope' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $graphAppId -PermissionType 'Scope' -PermissionValue 'User.Read'); type = 'Scope' }
                )
            }
            @{
                resourceAppId  = $spOnlineAppId
                resourceAccess = @(
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $spOnlineAppId -PermissionType 'Role' -PermissionValue 'Sites.FullControl.All'); type = 'Role' }
                    @{ id = (Resolve-ResourcePermissionId -ResourceAppId $spOnlineAppId -PermissionType 'Scope' -PermissionValue 'AllSites.FullControl'); type = 'Scope' }
                )
            }
        )

        # Check if app already exists
        $existingApps = Invoke-MgGraphRequest -Method GET `
            -Uri "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$appDisplayName'&`$select=appId,displayName"
        $existingApp = $existingApps.value | Select-Object -First 1

        if ($existingApp) {
            $existingClientId = $existingApp.appId
            Write-Status -Label 'Entra App' -Status "Found existing app: $appDisplayName ($existingClientId)" -Color 'Green'

            # Ensure publicClient config and delegated permissions are correct
            try {
                $fullApp = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$existingClientId'&`$select=id,publicClient"
                $appObjectId = $fullApp.value[0].id

                # Patch: add redirect URIs for all PnP auth methods + enable public client flows
                $patchBody = @{
                    publicClient = @{
                        redirectUris = @(
                            'https://login.microsoftonline.com/common/oauth2/nativeclient'
                            'http://localhost'
                            'http://127.0.0.1'
                            "ms-appx-web://microsoft.aad.brokerplugin/$existingClientId"
                        )
                    }
                    isFallbackPublicClient = $true
                    requiredResourceAccess = $requiredResourceAccess
                } | ConvertTo-Json -Depth 10
                Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/applications/$appObjectId" -Body $patchBody -ContentType 'application/json'
                Write-Status -Label 'Entra App' -Status 'Verified redirect URIs and public client flow' -Color 'Green'

                $appSpId = $null
                try {
                    $appSpId = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$existingClientId'&`$select=id").value[0].id
                    if ([string]::IsNullOrWhiteSpace([string]$appSpId)) {
                        throw "Could not resolve service principal for app '$existingClientId'."
                    }
                }
                catch {
                    Write-Status -Label 'Service Principal' -Status "Could not resolve app service principal: $($_.Exception.Message)" -Color 'Yellow'
                }

                if (-not [string]::IsNullOrWhiteSpace([string]$appSpId)) {
                    try {
                        $graphRoleResult = Ensure-ServicePrincipalAppRoleAssignments -ClientServicePrincipalId $appSpId -ResourceAppId $graphAppId -RoleValues $requiredGraphAppRoleValues
                        Write-Status -Label 'Graph App Roles' -Status $graphRoleResult.StatusMessage -Color 'Green'
                    }
                    catch {
                        Write-Status -Label 'Graph App Roles' -Status "Could not verify Graph app roles: $($_.Exception.Message)" -Color 'Yellow'
                    }
                }

                # Ensure SharePoint oauth2PermissionGrant exists for existing app too
                try {
                    if ([string]::IsNullOrWhiteSpace([string]$appSpId)) {
                        throw "Could not resolve service principal for app '$existingClientId'."
                    }
                    $spResourceId = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0ff1-ce00-000000000000'&`$select=id").value[0].id
                    $existingGrants = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$filter=clientId eq '$appSpId' and resourceId eq '$spResourceId'").value
                    if (-not $existingGrants -or $existingGrants.Count -eq 0) {
                        $grantBody = @{
                            clientId    = $appSpId
                            consentType = 'AllPrincipals'
                            resourceId  = $spResourceId
                            scope       = 'AllSites.FullControl'
                        } | ConvertTo-Json
                        Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants' -Body $grantBody -ContentType 'application/json' | Out-Null
                        Write-Status -Label 'SP Consent' -Status 'Created missing SharePoint permission grant' -Color 'Green'
                    } else {
                        Write-Status -Label 'SP Consent' -Status 'SharePoint permission grant verified' -Color 'Green'
                    }
                }
                catch {
                    Write-Status -Label 'SP Consent' -Status "Could not verify SP grant: $($_.Exception.Message)" -Color 'Yellow'
                }
            }
            catch {
                Write-Status -Label 'Entra App' -Status "Could not patch app config: $_" -Color 'Yellow'
            }
        } else {
            $appBody = @{
                displayName            = $appDisplayName
                signInAudience         = 'AzureADMyOrg'
                isFallbackPublicClient = $true
                publicClient           = @{
                    redirectUris = @(
                        'https://login.microsoftonline.com/common/oauth2/nativeclient'
                        'http://localhost'
                        'http://127.0.0.1'
                    )
                }
                requiredResourceAccess = $requiredResourceAccess
            } | ConvertTo-Json -Depth 10

            $newApp = Invoke-MgGraphRequest -Method POST `
                -Uri 'https://graph.microsoft.com/v1.0/applications' `
                -Body $appBody -ContentType 'application/json'

            $existingClientId = $newApp.appId
            Write-Status -Label 'Entra App' -Status "Created: $appDisplayName ($existingClientId)" -Color 'Green'

            # Add WAM broker redirect URI (requires clientId, so must be a separate PATCH)
            $appObjectId = $newApp.id
            $wamPatch = @{
                publicClient = @{
                    redirectUris = @(
                        'https://login.microsoftonline.com/common/oauth2/nativeclient'
                        'http://localhost'
                        'http://127.0.0.1'
                        "ms-appx-web://microsoft.aad.brokerplugin/$existingClientId"
                    )
                }
            } | ConvertTo-Json -Depth 5
            Invoke-MgGraphRequest -Method PATCH -Uri "https://graph.microsoft.com/v1.0/applications/$appObjectId" -Body $wamPatch -ContentType 'application/json'

            # Create service principal for the app
            $spBody = @{ appId = $existingClientId } | ConvertTo-Json
            $createdServicePrincipal = Invoke-MgGraphRequest -Method POST `
                -Uri 'https://graph.microsoft.com/v1.0/servicePrincipals' `
                -Body $spBody -ContentType 'application/json'
            Write-Status -Label 'Service Principal' -Status 'Created' -Color 'Green'

            Write-Host "`n  IMPORTANT: You must grant admin consent for the API permissions." -ForegroundColor Red
            Write-Host "  Open this URL in a browser and click 'Grant admin consent':" -ForegroundColor Yellow
            Write-Host "  https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$existingClientId" -ForegroundColor Cyan
            Write-Host "`n  Press Enter after granting admin consent..." -ForegroundColor Yellow
            Read-Host

            # Ensure SharePoint oauth2PermissionGrant exists
            # The portal "Grant admin consent" button sometimes silently fails to write the
            # SharePoint resource consent record, which causes PnP tenant admin operations
            # (Get-PnPTenant, New-PnPSite) to fail with "unauthorized operation".
            try {
                $appSpId = if ($null -ne $createdServicePrincipal -and -not [string]::IsNullOrWhiteSpace([string]$createdServicePrincipal.id)) {
                    [string]$createdServicePrincipal.id
                }
                else {
                    [string](Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '$existingClientId'&`$select=id").value[0].id
                }

                $graphRoleResult = Ensure-ServicePrincipalAppRoleAssignments -ClientServicePrincipalId $appSpId -ResourceAppId $graphAppId -RoleValues $requiredGraphAppRoleValues
                Write-Status -Label 'Graph App Roles' -Status $graphRoleResult.StatusMessage -Color 'Green'

                $spResourceId = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=appId eq '00000003-0000-0ff1-ce00-000000000000'&`$select=id").value[0].id
                $existingGrants = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/oauth2PermissionGrants?`$filter=clientId eq '$appSpId' and resourceId eq '$spResourceId'").value
                if (-not $existingGrants -or $existingGrants.Count -eq 0) {
                    $grantBody = @{
                        clientId    = $appSpId
                        consentType = 'AllPrincipals'
                        resourceId  = $spResourceId
                        scope       = 'AllSites.FullControl'
                    } | ConvertTo-Json
                    Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants' -Body $grantBody -ContentType 'application/json' | Out-Null
                    Write-Status -Label 'SP Consent' -Status 'Created SharePoint AllSites.FullControl permission grant' -Color 'Green'
                } else {
                    Write-Status -Label 'SP Consent' -Status 'SharePoint permission grant verified' -Color 'Green'
                }
            }
            catch {
                Write-Status -Label 'SP Consent' -Status "Could not verify SP grant: $($_.Exception.Message)" -Color 'Yellow'
                Write-Host "  If PnP tenant admin fails later, manually grant consent in the portal." -ForegroundColor Yellow
            }
        }

        Disconnect-MgGraph -ErrorAction SilentlyContinue
    }
    catch {
        Write-Status -Label 'Entra App' -Status "Auto-creation failed: $_" -Color 'Red'
        Write-Host "  You can create the app manually in the Azure portal and enter the Client ID below." -ForegroundColor Yellow
        $existingClientId = Prompt-Value -Prompt 'Entra App Client ID (or leave blank to skip)' -Default ''
    }
}

$config.SharePoint.PnPClientId = $existingClientId

# Auth mode -- default to OSLogin (WAM), most reliable on Windows 11 + PS 7
$config.SharePoint.PnPLoginMode = 'OSLogin'
Write-Status -Label 'Auth mode' -Status 'OSLogin (Windows native sign-in)' -Color 'Green'

# Environment bootstrap -- auto-derive, show as confirmation
$domainDefault = "$tenantName-workshop"
$config.EnvironmentBootstrap.DomainName = $domainDefault
Write-Host "`n  Environment domain: $domainDefault.crm.dynamics.com" -ForegroundColor White

$studentProvisioningConfigured = $false
$studentProvisioningCertificateReady = $true

# Student provisioning
Write-Host "`n--- Student Provisioning (Optional) ---" -ForegroundColor Cyan
if (Prompt-YesNo -Question 'Provision per-student environments?' -Default $false) {
    Write-Host "  Enter a path to a text/CSV file with one email per line," -ForegroundColor Yellow
    Write-Host "  or type emails one per line (empty line to finish):" -ForegroundColor Yellow
    $emailInput = Prompt-Value -Prompt 'File path or first email'
    $emails = [System.Collections.ArrayList]@()

    if ($emailInput -and (Test-Path -LiteralPath $emailInput -PathType Leaf)) {
        # Read from file
        try {
            $fileEmails = Get-Content -LiteralPath $emailInput -ErrorAction Stop | ForEach-Object {
                ($_ -split ',')[0].Trim()
            } | Where-Object { $_ -match '@' }
            foreach ($e in $fileEmails) { [void]$emails.Add($e) }
            Write-Status -Label 'Student file' -Status "Loaded $($emails.Count) email(s) from $emailInput" -Color 'Green'
            if ($emails.Count -eq 0) {
                Write-Status -Label 'Student file' -Status "No valid emails found in $emailInput (expected one email per line)" -Color 'Yellow'
            }
        }
        catch {
            Write-Status -Label 'Student file' -Status "Failed to read $emailInput : $_" -Color 'Red'
        }
    } else {
        # Manual entry -- first one already captured
        if ($emailInput -match '@') { [void]$emails.Add($emailInput.Trim()) }
        while ($true) {
            $email = Read-Host '  Email'
            if ([string]::IsNullOrWhiteSpace($email)) { break }
            [void]$emails.Add($email.Trim())
        }
    }

    if ($emails.Count -gt 0) {
        $studentProvisioningConfigured = $true
        $config.Identity.ParticipantEmails = @($emails)
        Write-Status -Label 'Students' -Status "$($emails.Count) email(s) configured" -Color 'Green'

        # Per-student provisioning requires app-only auth (certificate)
        Write-Host "`n  Per-student provisioning requires app-only (certificate) authentication." -ForegroundColor Yellow
        $studentProvisioningCertificateReady = $false
        $provisioningCertificate = $null

        $configuredThumbprint = [string]$config.SharePoint.PnPCertificateThumbprint
        if (-not (Test-PlaceholderValue -Value $configuredThumbprint)) {
            $provisioningCertificate = Get-CurrentUserCertificate -Thumbprint $configuredThumbprint
            if ($provisioningCertificate) {
                Write-Status -Label 'Certificate' -Status "Using existing local certificate ($($provisioningCertificate.Thumbprint))" -Color 'Green'
            }
            else {
                Write-Status -Label 'Certificate' -Status "Configured thumbprint '$configuredThumbprint' was not found locally -- looking for a .pfx or creating a new certificate." -Color 'Yellow'
            }
        }

        if ($provisioningCertificate -and $provisioningCertificate.NotAfter -le (Get-Date)) {
            Write-Status -Label 'Certificate' -Status "Configured certificate expired on $($provisioningCertificate.NotAfter.ToUniversalTime().ToString('u')) -- a new certificate is required." -Color 'Yellow'
            $provisioningCertificate = $null
        }

        if (-not $provisioningCertificate) {
            $pfxFiles = Get-ChildItem -Path $repoRoot -Filter '*.pfx' -ErrorAction SilentlyContinue
            if ($pfxFiles) {
                Write-Host "  Found .pfx file(s): $($pfxFiles.Name -join ', ')" -ForegroundColor Cyan
                if (Prompt-YesNo -Question "  Import $($pfxFiles[0].Name) into your certificate store?" -Default $true) {
                    try {
                        $provisioningCertificate = Import-WorkshopPfxCertificateFile -FilePath $pfxFiles[0].FullName
                        Write-Status -Label 'Certificate' -Status "Imported (thumbprint: $($provisioningCertificate.Thumbprint))" -Color 'Green'
                    }
                    catch {
                        Write-Status -Label 'Certificate' -Status "Import failed: $($_.Exception.Message)" -Color 'Red'
                    }
                }
            }
        }

        if ($provisioningCertificate -and $provisioningCertificate.NotAfter -le (Get-Date)) {
            Write-Status -Label 'Certificate' -Status "Imported certificate expired on $($provisioningCertificate.NotAfter.ToUniversalTime().ToString('u')) -- a new certificate is required." -Color 'Yellow'
            $provisioningCertificate = $null
        }

        if (-not $provisioningCertificate -and (Prompt-YesNo -Question '  Create a new self-signed workshop certificate now?' -Default $true)) {
            try {
                $certificateName = "Copilot Studio Workshop - $tenantName Provisioning"
                $provisioningCertificate = New-WorkshopSelfSignedCertificate -CommonName $certificateName -FriendlyName $certificateName
                Write-Status -Label 'Certificate' -Status "Created self-signed certificate (thumbprint: $($provisioningCertificate.Thumbprint))" -Color 'Green'
            }
            catch {
                Write-Status -Label 'Certificate' -Status "Certificate creation failed: $($_.Exception.Message)" -Color 'Red'
            }
        }

        if ($provisioningCertificate) {
            $config.SharePoint.PnPCertificateThumbprint = $provisioningCertificate.Thumbprint
            if ([string]::IsNullOrWhiteSpace($existingClientId) -or $existingClientId -match '^<') {
                Write-Status -Label 'Entra App' -Status 'No workshop app client ID is configured, so the certificate could not be registered for app-only auth.' -Color 'Yellow'
            }
            else {
                try {
                    Connect-WorkshopGraphAdminSession -TenantId $tenantId
                    $certificateRegistration = Ensure-WorkshopAppCertificateCredential -ClientId $existingClientId -Certificate $provisioningCertificate -DisplayName "Workshop Provisioning Certificate - $tenantName"
                    if ($certificateRegistration.Added) {
                        Write-Status -Label 'Entra App' -Status 'Registered certificate public key for app-only student provisioning' -Color 'Green'
                    }
                    else {
                        Write-Status -Label 'Entra App' -Status 'Certificate public key already registered for app-only student provisioning' -Color 'Green'
                    }
                    $studentProvisioningCertificateReady = $true
                }
                catch {
                    Write-Status -Label 'Entra App' -Status "Certificate registration failed: $($_.Exception.Message)" -Color 'Yellow'
                }
            }
        }
        else {
            Write-Status -Label 'Certificate' -Status 'No usable certificate is configured yet. Student provisioning will remain blocked until one is created or imported.' -Color 'Yellow'
        }

        $resolvedClientSecret = Resolve-ConfiguredClientSecret -Config $config
        if ($resolvedClientSecret.Value) {
            $clientSecretSource = if ($resolvedClientSecret.Source -eq 'EnvironmentVariable') {
                "environment variable '$($resolvedClientSecret.EnvironmentVariableName)'"
            }
            else {
                'workshop-config.json'
            }
            Write-Status -Label 'Client Secret' -Status "Already available via $clientSecretSource" -Color 'Green'
        }
        elseif ([string]::IsNullOrWhiteSpace($existingClientId) -or $existingClientId -match '^<') {
            Write-Status -Label 'Client Secret' -Status 'No workshop app client ID is configured, so client-secret generation was skipped.' -Color 'Yellow'
        }
        elseif (Prompt-YesNo -Question '  Generate and store a client secret for app-only PowerApps admin auth (for example DLP checks)?' -Default $false) {
            try {
                $clientSecretEnvVar = [string]$config.Identity.ClientSecretEnvVar
                if ((Test-PlaceholderValue -Value $clientSecretEnvVar) -or [string]::IsNullOrWhiteSpace($clientSecretEnvVar)) {
                    $clientSecretEnvVar = 'COPILOT_WORKSHOP_APP_SECRET'
                }

                $clientSecretEnvVar = Prompt-Value -Prompt '  Environment variable name for the client secret' -Default $clientSecretEnvVar -Required
                $existingEnvSecret = [Environment]::GetEnvironmentVariable($clientSecretEnvVar, 'User')
                if ([string]::IsNullOrWhiteSpace($existingEnvSecret) -or (Prompt-YesNo -Question "  Overwrite existing environment variable '$clientSecretEnvVar'?" -Default $false)) {
                    Connect-WorkshopGraphAdminSession -TenantId $tenantId
                    $clientSecretResult = New-WorkshopAppClientSecret -ClientId $existingClientId
                    Set-UserEnvironmentVariable -Name $clientSecretEnvVar -Value $clientSecretResult.SecretText
                    $config.Identity.ClientSecret = ''
                    $config.Identity.ClientSecretEnvVar = $clientSecretEnvVar
                    Write-Status -Label 'Client Secret' -Status "Stored in user environment variable '$clientSecretEnvVar' (expires $($clientSecretResult.EndDateTime.ToUniversalTime().ToString('u')))" -Color 'Green'
                }
                else {
                    Write-Status -Label 'Client Secret' -Status "Kept the existing value in environment variable '$clientSecretEnvVar'." -Color 'Yellow'
                }
            }
            catch {
                Write-Status -Label 'Client Secret' -Status "Generation or storage failed: $($_.Exception.Message)" -Color 'Yellow'
            }
        }
        else {
            Write-Status -Label 'Client Secret' -Status 'Skipped -- app-only PowerApps admin checks remain optional/manual, and Copilot credit allocation may still require manual PPAC steps.' -Color 'Yellow'
        }
    }
}

Disconnect-MgGraph -ErrorAction SilentlyContinue

# Save config
try {
    $config | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $ConfigPath -Encoding UTF8 -ErrorAction Stop
    Write-Status -Label 'Config' -Status "Saved to $ConfigPath" -Color 'Green'
}
catch {
    throw "Failed to save config to $ConfigPath : $_"
}

# ============================================================================
# Step 4: pac CLI Authentication
# ============================================================================
Write-Banner 'Step 4: Power Platform CLI Authentication'

if (Test-CommandAvailable -Name 'pac') {
    $pacAuthCheck = & pac auth list 2>&1 | ForEach-Object { $_.ToString() }
    $hasProfile = $pacAuthCheck | Select-String -Pattern '*' -SimpleMatch
    if ($hasProfile) {
        Write-Status -Label 'pac auth' -Status 'Active profile found' -Color 'Green'
        $pacAuthCheck | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    } else {
        Write-Status -Label 'pac auth' -Status 'No active profile -- launching interactive sign-in' -Color 'Yellow'
        Write-Host "`n  A browser window will open (or a device code will appear)." -ForegroundColor Yellow
        Write-Host "  Sign in with a Power Platform admin account.`n" -ForegroundColor Yellow
        & pac auth create 2>&1 | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
        if ($LASTEXITCODE -eq 0) {
            Write-Status -Label 'pac auth' -Status 'Authenticated successfully' -Color 'Green'
        } else {
            Write-Status -Label 'pac auth' -Status 'Authentication may have failed -- verify manually' -Color 'Yellow'
        }
    }
} else {
    Write-Status -Label 'pac auth' -Status 'pac CLI not available -- skipping' -Color 'Red'
}

# ============================================================================
# Step 5: Entra App Connectivity Test
# ============================================================================
Write-Banner 'Step 5: Entra App Connectivity Test'

$clientId = [string]$config.SharePoint.PnPClientId
$studentProvisioningConfigured = @($config.Identity.ParticipantEmails).Count -gt 0
$studentProvisioningCertificateReady = -not $studentProvisioningConfigured
if (-not [string]::IsNullOrWhiteSpace($clientId) -and $clientId -notmatch '^<') {
    if ($config.SharePoint.PnPLoginMode -eq 'CertificateThumbprint' -and -not [string]::IsNullOrWhiteSpace([string]$config.SharePoint.PnPCertificateThumbprint)) {
        try {
            Import-Module PnP.PowerShell -ErrorAction Stop
            Connect-PnPOnline -Url $config.SharePoint.AdminUrl -ClientId $clientId -Tenant $tenantId -Thumbprint $config.SharePoint.PnPCertificateThumbprint -ErrorAction Stop
            Write-Status -Label 'PnP connectivity' -Status 'Connected to SharePoint admin successfully' -Color 'Green'
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
        }
        catch {
            Write-Status -Label 'PnP connectivity' -Status "Failed: $_" -Color 'Red'
            Write-Host "  Verify the certificate is imported and admin consent is granted." -ForegroundColor Yellow
        }
    } else {
        # Test interactive auth (OSLogin/DeviceLogin/Interactive)
        Write-Status -Label 'PnP connectivity' -Status "Will use $($config.SharePoint.PnPLoginMode) -- connectivity tested during lab setup" -Color 'Green'
    }

    if ($studentProvisioningConfigured) {
        try {
            Import-Module Microsoft.Graph.Authentication -ErrorAction Stop | Out-Null
            Import-Module PnP.PowerShell -ErrorAction Stop | Out-Null
            $appOnlyReadiness = Test-AppOnlyCertificateReadiness -TenantId $tenantId -ClientId $clientId -Thumbprint ([string]$config.SharePoint.PnPCertificateThumbprint) -SharePointAdminUrl ([string]$config.SharePoint.AdminUrl)
            if ($appOnlyReadiness.CertificateFound -and -not $appOnlyReadiness.CertificateExpired -and $appOnlyReadiness.GraphConnected -and $appOnlyReadiness.SharePointConnected) {
                Write-Status -Label 'Student provisioning cert' -Status 'Graph + SharePoint app-only certificate auth succeeded' -Color 'Green'
                $studentProvisioningCertificateReady = $true
            }
            else {
                $studentProvisioningCertificateReady = $false
                $studentProvisioningMessage = if ($appOnlyReadiness.Errors.Count -gt 0) { $appOnlyReadiness.Errors -join ' | ' } else { 'Certificate-based app-only auth is not ready yet.' }
                Write-Status -Label 'Student provisioning cert' -Status $studentProvisioningMessage -Color 'Yellow'
            }
        }
        catch {
            $studentProvisioningCertificateReady = $false
            Write-Status -Label 'Student provisioning cert' -Status "Certificate readiness test failed: $($_.Exception.Message)" -Color 'Yellow'
        }
    }
} else {
    Write-Status -Label 'Entra App' -Status 'No Client ID configured -- skipping connectivity test' -Color 'Yellow'
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
        Write-Host '  WARNING: Labs 13, 16, 19, 21, and 24 require these assets.' -ForegroundColor Red
        Write-Host '  Retry with: pwsh -File .\workshop\automation\Get-WorkshopDay2Assets.ps1' -ForegroundColor Yellow
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
        Write-Status -Label 'Prerequisites' -Status 'Shared prerequisite checks passed' -Color 'Green'
    }
    catch {
        $errMsg = $_.Exception.Message
        if ($errMsg -match 'EnvironmentUrl' -or $errMsg -match 'placeholder') {
            Write-Status -Label 'Prerequisites' -Status 'Shared checks passed; facilitator EnvironmentUrl still needs capture or explicit override' -Color 'Yellow'
        } else {
            Write-Status -Label 'Prerequisites' -Status "Validation failed: $errMsg" -Color 'Red'
        }
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
    @{ Label = 'pac auth profile';       Check = { (Test-CommandAvailable -Name 'pac') -and ((& pac auth list 2>&1 | ForEach-Object { $_.ToString() }) | Select-String -Pattern '*' -SimpleMatch) } }
    @{
        Label = 'Day 2 assets'
        Check = {
            $assetsDir = Join-Path -Path $automationDir -ChildPath '..\assets'
            (Test-Path (Join-Path $assetsDir 'WoodgroveLending_1_0_0_0.zip')) -and
            (Test-Path (Join-Path $assetsDir 'loan-types.csv')) -and
            (Test-Path (Join-Path $assetsDir 'assessment-criteria.csv'))
        }
    }
)

if ($studentProvisioningConfigured) {
    $dashboard += @{
        Label = 'Student provisioning cert auth'
        Check = { $studentProvisioningCertificateReady }
    }
}

$allGreen = $true
$failedChecks = [System.Collections.ArrayList]@()
foreach ($item in $dashboard) {
    $pass = $false
    $checkError = $null
    try { $pass = & $item.Check } catch { $checkError = $_.Exception.Message }
    if ($pass) {
        Write-Host "  [PASS] $($item.Label)" -ForegroundColor Green
    } else {
        $detail = if ($checkError) { " ($checkError)" } else { '' }
        Write-Host "  [----] $($item.Label)$detail" -ForegroundColor Yellow
        [void]$failedChecks.Add($item.Label)
        $allGreen = $false
    }
}

Write-Host ''
if ($allGreen) {
    Write-Host '  Shared facilitator setup checks passed. Continue with manual environment, demo-path, and student-path validation as needed.' -ForegroundColor Green
} else {
    Write-Host "  $($failedChecks.Count) item(s) need attention: $($failedChecks -join ', ')" -ForegroundColor Yellow
    Write-Host '  Fix them and re-run the wizard, or proceed only when you have separately validated any manual facilitator or student gates.' -ForegroundColor Yellow
}

Write-Host "`n--- Next Steps ---" -ForegroundColor Cyan
Write-Host '  1. Pre-stage shared Day 1 site:' -ForegroundColor White
Write-Host '     pwsh -File .\workshop\automation\Invoke-WorkshopLabSetup.ps1 -Mode StudentReady' -ForegroundColor Gray
Write-Host ''
Write-Host '  2. Optional: Batch-provision per-student environments:' -ForegroundColor White
Write-Host '     pwsh -File .\workshop\automation\Invoke-StudentEnvironmentProvisioning.ps1' -ForegroundColor Gray
Write-Host ''
Write-Host '  3. Post-workshop cleanup:' -ForegroundColor White
Write-Host '     pwsh -File .\workshop\automation\Remove-StudentEnvironments.ps1 -HardDelete' -ForegroundColor Gray
Write-Host ''
