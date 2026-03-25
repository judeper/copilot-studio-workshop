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
$pnpLoginMode = [string]$sharePointConfig.PnPLoginMode

$studentMap = @(Read-StudentEnvironmentMap -Path $MapFilePath)
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

$environmentDeletePollIntervalSeconds = 15
$environmentDeleteTimeoutMinutes = 10

function Test-IsAlreadyAbsentError {
    param(
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )

    $message = [string]$ErrorRecord.Exception.Message
    return $message -match '(?i)\bnot found\b|does not exist|cannot find|already deleted|already removed|404|resource.*not exist|object.*not exist'
}

function Connect-SharePointDelegatedWithFallback {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$LoginMode,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $effectiveLoginMode = switch ($LoginMode) {
        'OSLogin' { 'OSLogin' }
        'Interactive' { 'Interactive' }
        'DeviceLogin' { 'DeviceLogin' }
        default { 'DeviceLogin' }
    }

    if ($effectiveLoginMode -ne $LoginMode) {
        Write-Log -Level INFO -Message "SharePoint login mode '$LoginMode' can't be used for delegated fallback. Using '$effectiveLoginMode' instead." -Component 'SP'
    }

    $methods = switch ($effectiveLoginMode) {
        'OSLogin' { @('OSLogin', 'DeviceLogin') }
        'Interactive' { @('Interactive', 'DeviceLogin') }
        default { @('DeviceLogin') }
    }

    $lastError = $null
    foreach ($method in $methods) {
        try {
            Write-Log -Level INFO -Message "Connecting to $Label using delegated PnP login mode '$method'." -Component 'SP'
            switch ($method) {
                'OSLogin' {
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -OSLogin -ErrorAction Stop
                }
                'Interactive' {
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop
                }
                'DeviceLogin' {
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $TenantId -DeviceLogin -ErrorAction Stop
                }
            }

            return
        }
        catch {
            $lastError = $_
            if ($methods.Count -gt 1 -and $method -ne $methods[-1]) {
                Write-Log -Level WARN -Message "$method failed for ${Label}: $($_.Exception.Message). Trying fallback..." -Component 'SP'
            }
        }
    }

    throw "Unable to connect to $Label after trying $($methods -join ', '). Last error: $lastError"
}

function Invoke-SharePointAdminCleanupOperation {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Operation,

        [Parameter(Mandatory = $true)]
        [string]$FailureContext
    )

    try {
        & $Operation
        return
    }
    catch {
        if (Test-IsAlreadyAbsentError -ErrorRecord $_) {
            Write-Log -Level PASS -Message "$FailureContext is already complete." -Component 'SP'
            return
        }

        $message = [string]$_.Exception.Message
        if ($message -match '(?i)unauthorized|access denied|401|403') {
            Write-Log -Level WARN -Message "$FailureContext failed under app-only auth: $message. Falling back to delegated SharePoint admin sign-in." -Component 'SP'
            Disconnect-PnPOnline -ErrorAction SilentlyContinue
            Connect-SharePointDelegatedWithFallback `
                -Url $adminUrl `
                -TenantId $tenantId `
                -ClientId $pnpClientId `
                -LoginMode $pnpLoginMode `
                -Label 'the SharePoint admin center'

            try {
                & $Operation
                return
            }
            catch {
                if (Test-IsAlreadyAbsentError -ErrorRecord $_) {
                    Write-Log -Level PASS -Message "$FailureContext is already complete." -Component 'SP'
                    return
                }

                throw
            }
        }

        throw
    }
}

function Normalize-EnvironmentUrl {
    param(
        [Parameter()]
        [string]$Url
    )

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $null
    }

    return $Url.Trim().TrimEnd('/')
}

function Get-PacAdminEnvironmentRecord {
    param(
        [Parameter()]
        [string]$EnvironmentUrl,

        [Parameter()]
        [string]$EnvironmentGuid
    )

    $normalizedEnvironmentUrl = Normalize-EnvironmentUrl -Url $EnvironmentUrl
    $pacOutput = & pac admin list --json 2>&1
    $pacOutputText = ($pacOutput | Out-String).Trim()

    if ($pacOutputText -match '(?mi)^Error:') {
        throw "pac admin list failed. $pacOutputText"
    }

    if ([string]::IsNullOrWhiteSpace($pacOutputText)) {
        return $null
    }

    $jsonStartIndex = $pacOutputText.IndexOf('[')
    $jsonEndIndex = $pacOutputText.LastIndexOf(']')
    if ($jsonStartIndex -lt 0 -or $jsonEndIndex -lt $jsonStartIndex) {
        throw "pac admin list did not return JSON. Output: $pacOutputText"
    }

    $jsonText = $pacOutputText.Substring($jsonStartIndex, $jsonEndIndex - $jsonStartIndex + 1)
    $environments = @($jsonText | ConvertFrom-Json -Depth 10)

    return $environments | Where-Object {
        ($EnvironmentGuid -and $_.EnvironmentId -eq $EnvironmentGuid) -or
        ($normalizedEnvironmentUrl -and (Normalize-EnvironmentUrl -Url ([string]$_.EnvironmentUrl)) -eq $normalizedEnvironmentUrl)
    } | Select-Object -First 1
}

function Wait-ForPacEnvironmentDeletion {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Student,

        [Parameter()]
        [int]$PollIntervalSeconds = $environmentDeletePollIntervalSeconds,

        [Parameter()]
        [int]$TimeoutMinutes = $environmentDeleteTimeoutMinutes
    )

    $deadline = (Get-Date).AddMinutes($TimeoutMinutes)
    $pollCount = 0

    while ((Get-Date) -lt $deadline) {
        $existingEnvironment = Get-PacAdminEnvironmentRecord -EnvironmentUrl $student.EnvironmentUrl -EnvironmentGuid $student.EnvironmentGuid
        if (-not $existingEnvironment) {
            Write-Log -Level PASS -Message 'Power Platform environment deletion verified.' -Component 'ENV'
            return $true
        }

        $pollCount++
        Write-Log -Level INFO -Message "Environment delete is still in progress (check $pollCount). Waiting ${PollIntervalSeconds}s before rechecking..." -Component 'ENV'
        Start-Sleep -Seconds $PollIntervalSeconds
    }

    $existingEnvironment = Get-PacAdminEnvironmentRecord -EnvironmentUrl $student.EnvironmentUrl -EnvironmentGuid $student.EnvironmentGuid
    if (-not $existingEnvironment) {
        Write-Log -Level PASS -Message 'Power Platform environment deletion verified.' -Component 'ENV'
        return $true
    }

    Write-Log -Level WARN -Message "Environment delete was requested but not confirmed within ${TimeoutMinutes} minute(s); leaving the map entry for follow-up." -Component 'ENV'
    return $false
}

function Remove-PacAdminEnvironment {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Student
    )

    $existingEnvironment = Get-PacAdminEnvironmentRecord -EnvironmentUrl $Student.EnvironmentUrl -EnvironmentGuid $Student.EnvironmentGuid
    if (-not $existingEnvironment) {
        Write-Log -Level PASS -Message 'Power Platform environment is already absent.' -Component 'ENV'
        return $true
    }

    $environmentIdentifier = if (-not [string]::IsNullOrWhiteSpace([string]$Student.EnvironmentGuid)) {
        $Student.EnvironmentGuid
    } else {
        $Student.EnvironmentUrl
    }

    Write-Log -Level INFO -Message "Submitting asynchronous delete request for environment: $($existingEnvironment.DisplayName) ($($existingEnvironment.EnvironmentUrl))" -Component 'ENV'
    $deleteOutput = & pac admin delete --environment $environmentIdentifier --async 2>&1
    $deleteOutputText = ($deleteOutput | Out-String).Trim()

    if ($deleteOutputText -match '(?mi)^Error:') {
        Write-Log -Level WARN -Message "pac admin delete failed for $environmentIdentifier. $deleteOutputText" -Component 'ENV'
        return $false
    }

    Write-Log -Level INFO -Message "Delete request submitted. Polling pac admin list every ${environmentDeletePollIntervalSeconds}s for up to ${environmentDeleteTimeoutMinutes} minute(s)." -Component 'ENV'
    return Wait-ForPacEnvironmentDeletion -Student $Student
}

Write-Section 'Cleaning up student environments'

$completedCleanupStudents = New-Object System.Collections.Generic.List[string]

foreach ($student in $studentMap) {
    $email = $student.Email
    $alias = $student.Alias
    Write-Log -Level INFO -Message "Cleaning up $email ($alias)..." -Component 'CLEANUP'

    if (-not $PSCmdlet.ShouldProcess($email, 'Remove student environment')) {
        continue
    }

    $artifactCleanupComplete = $true

    # Step 1: Soft-delete M365 Group (cascades to Teams + SharePoint)
    if ($student.GroupId) {
        try {
            Write-Log -Level INFO -Message "Soft-deleting M365 Group $($student.GroupId)..." -Component 'GROUP'
            Remove-PnPMicrosoft365Group -Identity $student.GroupId -ErrorAction Stop
            Write-Log -Level PASS -Message 'M365 Group soft-deleted.' -Component 'GROUP'
        }
        catch {
            if (Test-IsAlreadyAbsentError -ErrorRecord $_) {
                Write-Log -Level PASS -Message 'M365 Group is already absent.' -Component 'GROUP'
            }
            else {
                $artifactCleanupComplete = $false
                Write-Log -Level WARN -Message "M365 Group delete failed: $_" -Component 'GROUP'
            }
        }
    } elseif ($student.SharePointUrl) {
        # Try to find group by site URL
        Write-Log -Level INFO -Message "No GroupId recorded — attempting to delete SharePoint site directly." -Component 'SP'
        try {
            Invoke-SharePointAdminCleanupOperation `
                -FailureContext "SharePoint site delete for $($student.SharePointUrl)" `
                -Operation { Remove-PnPTenantSite -Url $student.SharePointUrl -Force -ErrorAction Stop }
            Write-Log -Level PASS -Message "SharePoint site deleted: $($student.SharePointUrl)" -Component 'SP'
        }
        catch {
            $artifactCleanupComplete = $false
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
                if (Test-IsAlreadyAbsentError -ErrorRecord $_) {
                    Write-Log -Level PASS -Message 'M365 Group is already absent from the Entra recycle bin.' -Component 'GROUP'
                }
                else {
                    $artifactCleanupComplete = $false
                    Write-Log -Level WARN -Message "Hard-delete of M365 Group failed: $_" -Component 'GROUP'
                }
            }
        }

        # Step 3: Hard-delete SharePoint site from site collection recycle bin
        if ($student.SharePointUrl) {
            try {
                Invoke-SharePointAdminCleanupOperation `
                    -FailureContext "SharePoint recycle-bin purge for $($student.SharePointUrl)" `
                    -Operation { Remove-PnPTenantDeletedSite -Identity $student.SharePointUrl -Force -ErrorAction Stop }
                Write-Log -Level PASS -Message "SharePoint site permanently purged: $($student.SharePointUrl)" -Component 'SP'
            }
            catch {
                $artifactCleanupComplete = $false
                Write-Log -Level WARN -Message "SharePoint site purge failed: $_" -Component 'SP'
            }
        }
    }

    # Step 4: Delete Power Platform environment
    $environmentCleanupComplete = $true
    if ($student.EnvironmentUrl -or $student.EnvironmentGuid) {
        try {
            if ($SkipEnvironmentDelete) {
                $environmentCleanupComplete = -not (Get-PacAdminEnvironmentRecord -EnvironmentUrl $student.EnvironmentUrl -EnvironmentGuid $student.EnvironmentGuid)
                if ($environmentCleanupComplete) {
                    Write-Log -Level PASS -Message 'Power Platform environment is already absent.' -Component 'ENV'
                } else {
                    Write-Log -Level INFO -Message 'Skipping environment delete by request; leaving the map entry for follow-up.' -Component 'ENV'
                }
            } else {
                $environmentCleanupComplete = Remove-PacAdminEnvironment -Student $student
            }
        }
        catch {
            $environmentCleanupComplete = $false
            Write-Log -Level WARN -Message "Environment delete failed: $_" -Component 'ENV'
        }
    }

    $hasRecordedSharePointOrGroupArtifacts = (-not [string]::IsNullOrWhiteSpace([string]$student.GroupId)) -or (-not [string]::IsNullOrWhiteSpace([string]$student.SharePointUrl))
    $cleanupVerified = if ($HardDelete) {
        $artifactCleanupComplete -and $environmentCleanupComplete
    } else {
        (-not $hasRecordedSharePointOrGroupArtifacts) -and $environmentCleanupComplete
    }

    if ($cleanupVerified) {
        $completedCleanupStudents.Add($email)
        Write-Log -Level INFO -Message 'Cleanup is verified for this student; the map entry will be removed.' -Component 'CLEANUP'
    }
}

Disconnect-PnPOnline -ErrorAction SilentlyContinue

$shouldUpdateMap = -not [bool]$WhatIfPreference

if (-not $shouldUpdateMap) {
    Write-Log -Level INFO -Message 'Skipping student map updates because -WhatIf is active.'
} elseif ($HardDelete) {
    if ($completedCleanupStudents.Count -eq $studentMap.Count) {
        Write-Log -Level INFO -Message 'Clearing student environment map after verified hard delete.'
        Save-StudentEnvironmentMap -Path $MapFilePath -StudentMap @()
    } elseif ($completedCleanupStudents.Count -gt 0) {
        $remainingStudents = @(
            $studentMap | Where-Object {
                $completedCleanupStudents -notcontains $_.Email
            }
        )
        $entryLabel = if ($completedCleanupStudents.Count -eq 1) { 'entry' } else { 'entries' }
        Write-Log -Level WARN -Message "Cleanup is verified for $($completedCleanupStudents.Count) $entryLabel, but some student resources still need follow-up. Keeping the remaining map entries."
        Save-StudentEnvironmentMap -Path $MapFilePath -StudentMap $remainingStudents
    } else {
        Write-Log -Level WARN -Message 'Hard delete was requested, but no student cleanup entries were verified as complete. Leaving the map unchanged.'
    }
} elseif ($completedCleanupStudents.Count -gt 0) {
    $remainingStudents = @(
        $studentMap | Where-Object {
            $completedCleanupStudents -notcontains $_.Email
        }
    )
    $entryLabel = if ($completedCleanupStudents.Count -eq 1) { 'entry' } else { 'entries' }
    Write-Log -Level INFO -Message "Removing $($completedCleanupStudents.Count) completed cleanup $entryLabel from the map."
    Save-StudentEnvironmentMap -Path $MapFilePath -StudentMap $remainingStudents
}

Write-Log -Level PASS -Message 'Student environment cleanup complete.'
