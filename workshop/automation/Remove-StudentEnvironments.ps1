[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$MapFilePath = (Join-Path -Path $PSScriptRoot -ChildPath 'student-environment-map.json'),

    [Parameter()]
    [switch]$HardDelete,

    [Parameter()]
    [switch]$SkipEnvironmentDelete
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

Initialize-WorkshopLog -ScriptName 'StudentCleanup'

Write-Section 'Loading configuration and student map'

$config = Get-WorkshopConfig -Path $ConfigPath
$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'

$sharePointConfig = $config.SharePoint
$adminUrl = Get-RequiredString -Value ([string]$sharePointConfig.AdminUrl) -Name 'SharePoint.AdminUrl'
$pnpClientId = Get-RequiredString -Value ([string]$sharePointConfig.PnPClientId) -Name 'SharePoint.PnPClientId'
$pnpCertThumbprint = [string]$sharePointConfig.PnPCertificateThumbprint

$studentMap = Read-StudentEnvironmentMap -Path $MapFilePath
if ($studentMap.Count -eq 0) {
    Write-Log -Level INFO -Message 'Student map is empty — nothing to clean up.'
    return
}

Write-Log -Level INFO -Message "Found $($studentMap.Count) student entries to clean up."

Write-Section 'Authenticating services'

Require-Command -Name 'pac'
Require-Module -Name 'PnP.PowerShell'

Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop
Write-Log -Level PASS -Message 'Connected to SharePoint admin center.'

Write-Section 'Cleaning up student environments'

foreach ($student in $studentMap) {
    $email = $student.Email
    $alias = $student.Alias
    Write-Log -Level INFO -Message "Cleaning up $email ($alias)..." -Component 'CLEANUP'

    if (-not $PSCmdlet.ShouldProcess($email, 'Remove student environment')) {
        continue
    }

    # Step 1: Soft-delete M365 Group (cascades to Teams + SharePoint)
    if ($student.GroupId) {
        try {
            Write-Log -Level INFO -Message "Soft-deleting M365 Group $($student.GroupId)..." -Component 'GROUP'
            Remove-PnPMicrosoft365Group -Identity $student.GroupId -ErrorAction Stop
            Write-Log -Level PASS -Message 'M365 Group soft-deleted.' -Component 'GROUP'
        }
        catch {
            Write-Log -Level WARN -Message "M365 Group delete failed: $_" -Component 'GROUP'
        }
    } elseif ($student.SharePointUrl) {
        # Try to find group by site URL
        Write-Log -Level INFO -Message "No GroupId recorded — attempting to delete SharePoint site directly." -Component 'SP'
        try {
            Remove-PnPTenantSite -Url $student.SharePointUrl -Force -ErrorAction Stop
            Write-Log -Level PASS -Message "SharePoint site deleted: $($student.SharePointUrl)" -Component 'SP'
        }
        catch {
            Write-Log -Level WARN -Message "SharePoint site delete failed: $_" -Component 'SP'
        }
    }

    if ($HardDelete) {
        Write-Log -Level INFO -Message 'Waiting 60 seconds for soft-delete propagation...' -Component 'CLEANUP'
        Start-Sleep -Seconds 60

        # Step 2: Hard-delete M365 Group from Entra recycle bin
        if ($student.GroupId) {
            try {
                Remove-PnPDeletedMicrosoft365Group -Identity $student.GroupId -ErrorAction Stop
                Write-Log -Level PASS -Message 'M365 Group permanently deleted from Entra recycle bin.' -Component 'GROUP'
            }
            catch {
                Write-Log -Level WARN -Message "Hard-delete of M365 Group failed: $_" -Component 'GROUP'
            }
        }

        # Step 3: Hard-delete SharePoint site from site collection recycle bin
        if ($student.SharePointUrl) {
            try {
                Remove-PnPTenantDeletedSite -Identity $student.SharePointUrl -Force
                Write-Log -Level PASS -Message "SharePoint site permanently purged: $($student.SharePointUrl)" -Component 'SP'
            }
            catch {
                Write-Log -Level WARN -Message "SharePoint site purge failed: $_" -Component 'SP'
            }
        }
    }

    # Step 4: Delete Power Platform environment
    if (-not $SkipEnvironmentDelete -and $student.EnvironmentUrl) {
        try {
            Write-Log -Level INFO -Message "Deleting environment: $($student.EnvironmentUrl)" -Component 'ENV'
            & pac admin delete --environment $student.EnvironmentUrl 2>&1 | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Log -Level WARN -Message "pac admin delete failed for $($student.EnvironmentUrl)" -Component 'ENV'
            } else {
                Write-Log -Level PASS -Message 'Power Platform environment deleted.' -Component 'ENV'
            }
        }
        catch {
            Write-Log -Level WARN -Message "Environment delete failed: $_" -Component 'ENV'
        }
    }
}

Disconnect-PnPOnline -ErrorAction SilentlyContinue

# Clear the map file after successful cleanup
if ($HardDelete) {
    Write-Log -Level INFO -Message 'Clearing student environment map after hard delete.'
    Save-StudentEnvironmentMap -Path $MapFilePath -StudentMap @()
}

Write-Log -Level PASS -Message 'Student environment cleanup complete.'
