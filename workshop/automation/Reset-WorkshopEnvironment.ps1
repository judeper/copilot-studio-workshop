<#
.SYNOPSIS
    Resets the shared workshop environment for re-testing.
.DESCRIPTION
    Deletes the shared Contoso IT SharePoint site (and optionally the Entra app
    registration and MSAL token caches) so the facilitator can re-run the bootstrap
    and lab setup scripts from scratch.

    This script handles the shared facilitator environment. For per-student cleanup,
    use Remove-StudentEnvironments.ps1 instead.
.PARAMETER HardDelete
    Purges the SharePoint site from the recycle bin after soft-delete. Required for
    immediate re-creation of the site — without this, the URL remains reserved for
    up to 93 days.
.PARAMETER IncludeEntraApp
    Also deletes the Entra app registration used for PnP authentication. The bootstrap
    wizard will recreate it on the next run.
.PARAMETER IncludeTokenCache
    Clears local MSAL token caches to force fresh authentication on next run.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$HardDelete,

    [Parameter()]
    [switch]$IncludeEntraApp,

    [Parameter()]
    [switch]$IncludeTokenCache
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

# ── Phase 1: Load configuration ─────────────────────────────────────────────

Write-Section 'Phase 1: Loading configuration'

$config = Get-WorkshopConfig -Path $ConfigPath
$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'

$sharePointConfig = $config.SharePoint
$adminUrl = Get-RequiredString -Value ([string]$sharePointConfig.AdminUrl) -Name 'SharePoint.AdminUrl'
$siteUrl  = Get-RequiredString -Value ([string]$sharePointConfig.SiteUrl)  -Name 'SharePoint.SiteUrl'
$pnpClientId = Get-RequiredString -Value ([string]$sharePointConfig.PnPClientId) -Name 'SharePoint.PnPClientId'

Write-StepResult -Level PASS -Message "Config loaded — site target: $siteUrl"

# ── Phase 2: Connect to SharePoint admin ─────────────────────────────────────

Write-Section 'Phase 2: Authenticating to SharePoint admin center'

Require-Module -Name 'PnP.PowerShell'

$pnpLoginMode = [string]$sharePointConfig.PnPLoginMode
if ([string]::IsNullOrWhiteSpace($pnpLoginMode)) {
    $pnpLoginMode = 'DeviceLogin'
}

Write-StepResult -Level INFO -Message "Login mode: $pnpLoginMode"

switch ($pnpLoginMode) {
    'DeviceLogin' {
        Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -DeviceLogin -ErrorAction Stop
    }
    'Interactive' {
        Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Interactive -ErrorAction Stop
    }
    default {
        Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -DeviceLogin -ErrorAction Stop
    }
}

Write-StepResult -Level PASS -Message 'Connected to SharePoint admin center.'

# ── Phase 3: Delete shared SharePoint site ───────────────────────────────────

Write-Section 'Phase 3: Deleting shared SharePoint site'

$siteDeleted  = $false
$sitePurged   = $false

# Check if the site exists as an active site collection
$existingSite = Get-PnPTenantSite -Identity $siteUrl -ErrorAction SilentlyContinue

if ($null -ne $existingSite) {
    if ($PSCmdlet.ShouldProcess($siteUrl, 'Soft-delete SharePoint site')) {
        Write-StepResult -Level INFO -Message "Soft-deleting site: $siteUrl"
        Remove-PnPTenantSite -Url $siteUrl -Force
        $siteDeleted = $true
        Write-StepResult -Level PASS -Message 'SharePoint site soft-deleted.'
    }
} else {
    Write-StepResult -Level INFO -Message 'Site does not exist as an active site collection.'
}

# Check the recycle bin for a leftover deleted site (from this run or a previous one)
if ($HardDelete) {
    if ($siteDeleted) {
        Write-StepResult -Level INFO -Message 'Waiting 30 seconds for soft-delete propagation...'
        Start-Sleep -Seconds 30
    }

    $deletedSite = Get-PnPTenantDeletedSite -Identity $siteUrl -ErrorAction SilentlyContinue

    if ($null -ne $deletedSite) {
        if ($PSCmdlet.ShouldProcess($siteUrl, 'Permanently purge SharePoint site from recycle bin')) {
            Write-StepResult -Level INFO -Message "Purging site from recycle bin: $siteUrl"
            Remove-PnPTenantDeletedSite -Identity $siteUrl -Force
            $sitePurged = $true
            Write-StepResult -Level PASS -Message 'SharePoint site permanently purged from recycle bin.'
        }
    } else {
        Write-StepResult -Level INFO -Message 'Site not found in the recycle bin — nothing to purge.'
    }
}

Disconnect-PnPOnline -ErrorAction SilentlyContinue

# ── Phase 4: Optionally delete Entra app registration ────────────────────────

$appDeleted = $false

if ($IncludeEntraApp) {
    Write-Section 'Phase 4: Deleting Entra app registration'

    Require-Module -Name 'Microsoft.Graph.Authentication'

    Write-StepResult -Level INFO -Message 'Connecting to Microsoft Graph...'
    Connect-MgGraph -TenantId $tenantId -Scopes 'Application.ReadWrite.All' -UseDeviceCode -NoWelcome

    $appResponse = Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/applications?`$filter=appId eq '$pnpClientId'&`$select=id,displayName,appId"

    $app = $appResponse.value | Select-Object -First 1

    if ($null -ne $app) {
        if ($PSCmdlet.ShouldProcess("$($app.displayName) ($pnpClientId)", 'Delete Entra app registration')) {
            Write-StepResult -Level INFO -Message "Deleting app: $($app.displayName) (objectId=$($app.id))"
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/v1.0/applications/$($app.id)"
            $appDeleted = $true
            Write-StepResult -Level PASS -Message 'Entra app registration deleted.'
        }
    } else {
        Write-StepResult -Level INFO -Message "No Entra app found with appId '$pnpClientId'."
    }

    Disconnect-MgGraph -ErrorAction SilentlyContinue
} else {
    Write-StepResult -Level INFO -Message 'Skipping Entra app deletion (use -IncludeEntraApp to include).'
}

# ── Phase 5: Optionally clear MSAL token caches ─────────────────────────────

$cacheCleared = $false

if ($IncludeTokenCache) {
    Write-Section 'Phase 5: Clearing MSAL token caches'

    $cachePatterns = @(
        (Join-Path -Path $env:LOCALAPPDATA -ChildPath '.IdentityService\msal*.cache'),
        (Join-Path -Path $env:LOCALAPPDATA -ChildPath '.IdentityService\mg.msal*')
    )

    foreach ($pattern in $cachePatterns) {
        $files = Get-Item -Path $pattern -ErrorAction SilentlyContinue
        if ($files) {
            foreach ($file in $files) {
                if ($PSCmdlet.ShouldProcess($file.FullName, 'Delete token cache file')) {
                    Remove-Item -LiteralPath $file.FullName -Force -ErrorAction SilentlyContinue
                    Write-StepResult -Level PASS -Message "Removed: $($file.Name)"
                    $cacheCleared = $true
                }
            }
        }
    }

    if (-not $cacheCleared) {
        Write-StepResult -Level INFO -Message 'No MSAL token cache files found.'
    }
} else {
    Write-StepResult -Level INFO -Message 'Skipping token cache cleanup (use -IncludeTokenCache to include).'
}

# ── Summary ──────────────────────────────────────────────────────────────────

Write-Section 'Reset summary'

$actions = @()
if ($siteDeleted)  { $actions += 'SharePoint site soft-deleted' }
if ($sitePurged)   { $actions += 'SharePoint site purged from recycle bin' }
if ($appDeleted)   { $actions += 'Entra app registration deleted' }
if ($cacheCleared) { $actions += 'MSAL token caches cleared' }

if ($actions.Count -eq 0) {
    Write-StepResult -Level INFO -Message 'No changes were made. The environment may already be clean, or -WhatIf was used.'
} else {
    foreach ($action in $actions) {
        Write-StepResult -Level PASS -Message $action
    }
    Write-StepResult -Level PASS -Message 'Workshop environment reset complete. You can now re-run the bootstrap and lab setup scripts.'
}
