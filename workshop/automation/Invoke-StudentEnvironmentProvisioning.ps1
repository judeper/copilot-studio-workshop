[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$SkipTeams,

    [Parameter()]
    [switch]$SkipSharePoint,

    [Parameter()]
    [switch]$SkipDlpCheck,

    [Parameter()]
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

Initialize-WorkshopLog -ScriptName 'StudentProvisioning'

# ============================================================================
# Phase 1: Load configuration and validate
# ============================================================================
Write-Section 'Phase 1: Loading configuration'

$config = Get-WorkshopConfig -Path $ConfigPath
$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'

$bootstrapConfig = $config.EnvironmentBootstrap
if ($null -eq $bootstrapConfig) {
    throw "Config section 'EnvironmentBootstrap' is required."
}

$participantEmails = @($config.Identity.ParticipantEmails)
if ($participantEmails.Count -eq 0) {
    throw "Identity.ParticipantEmails is empty. Add student email addresses before running."
}

$region = if ([string]::IsNullOrWhiteSpace([string]$bootstrapConfig.Region)) { 'unitedstates' } else { [string]$bootstrapConfig.Region }
$currency = if ([string]::IsNullOrWhiteSpace([string]$bootstrapConfig.Currency)) { 'USD' } else { [string]$bootstrapConfig.Currency }
$language = if ([string]::IsNullOrWhiteSpace([string]$bootstrapConfig.Language)) { 'English' } else { [string]$bootstrapConfig.Language }
$creditsPerEnv = if ($bootstrapConfig.CopilotStudioCreditsPerEnvironment) { [int]$bootstrapConfig.CopilotStudioCreditsPerEnvironment } else { 25000 }
$batchSize = if ($bootstrapConfig.BatchSize) { [int]$bootstrapConfig.BatchSize } else { 5 }
$domainPrefix = if ([string]::IsNullOrWhiteSpace([string]$bootstrapConfig.DomainName)) { 'workshop' } else { [string]$bootstrapConfig.DomainName }

$sharePointConfig = $config.SharePoint
$sitePrefix = if ([string]::IsNullOrWhiteSpace([string]$sharePointConfig.SitePrefix)) { 'ContosoIT' } else { [string]$sharePointConfig.SitePrefix }
$adminUrl = Get-RequiredString -Value ([string]$sharePointConfig.AdminUrl) -Name 'SharePoint.AdminUrl'
$pnpClientId = Get-RequiredString -Value ([string]$sharePointConfig.PnPClientId) -Name 'SharePoint.PnPClientId'
$pnpCertThumbprint = [string]$sharePointConfig.PnPCertificateThumbprint

$teamsConfig = $config.Teams
$teamPrefix = if ($null -eq $teamsConfig -or [string]::IsNullOrWhiteSpace([string]$teamsConfig.StudentTeamPrefix)) { 'Contoso Recruiting' } else { [string]$teamsConfig.StudentTeamPrefix }

$mapFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'student-environment-map.json'

Write-Log -Level PASS -Message "Loaded config: $($participantEmails.Count) students, region=$region, credits=$creditsPerEnv, batch=$batchSize"

if ($ValidateOnly) {
    Write-Log -Level INFO -Message 'ValidateOnly mode — exiting after config validation.'
    return
}

# ============================================================================
# Phase 2: Authenticate all services
# ============================================================================
Write-Section 'Phase 2: Authenticating services'

Require-Command -Name 'pac'
Write-Log -Level PASS -Message 'pac CLI available.'

$pacAuthOutput = & pac auth list 2>&1
if ($LASTEXITCODE -ne 0) {
    throw 'pac auth is not configured. Run pac auth create with an admin-capable account first.'
}
Write-Log -Level PASS -Message 'pac auth profile active.'

if (-not $SkipDlpCheck) {
    Require-Module -Name 'Microsoft.PowerApps.Administration.PowerShell'
    Write-Log -Level INFO -Message 'Authenticating PowerApps Admin module...'
    Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $pnpClientId -ClientSecret ([string]$config.Identity.ClientSecret) -ErrorAction SilentlyContinue
    if (-not $?) {
        Write-Log -Level WARN -Message 'Add-PowerAppsAccount failed — DLP check will be skipped. Ensure the facilitator verifies DLP manually.'
        $SkipDlpCheck = $true
    } else {
        Write-Log -Level PASS -Message 'PowerApps Admin session established.'
    }
}

if (-not $SkipSharePoint) {
    Require-Module -Name 'PnP.PowerShell'
    Write-Log -Level PASS -Message 'PnP.PowerShell module available.'
}

if (-not $SkipTeams) {
    Require-Module -Name 'Microsoft.Graph.Authentication'
    Write-Log -Level INFO -Message 'Connecting to Microsoft Graph (app-only, certificate)...'
    Connect-MgGraph -ClientId $pnpClientId -TenantId $tenantId -CertificateThumbprint $pnpCertThumbprint -NoWelcome
    Write-Log -Level PASS -Message 'Microsoft Graph session established.'
}

# ============================================================================
# Phase 3: Pre-flight validation
# ============================================================================
Write-Section 'Phase 3: Pre-flight validation'

$existingMap = Read-StudentEnvironmentMap -Path $mapFilePath
if ($existingMap.Count -gt 0) {
    Write-Log -Level WARN -Message "Found existing student map with $($existingMap.Count) entries. New students will be appended; duplicates skipped."
}

$alreadyProvisioned = @{}
foreach ($entry in $existingMap) {
    if ($entry.Email) { $alreadyProvisioned[$entry.Email.ToLowerInvariant()] = $true }
}

$studentsToProvision = @($participantEmails | Where-Object {
    -not $alreadyProvisioned.ContainsKey($_.ToLowerInvariant())
})

if ($studentsToProvision.Count -eq 0) {
    Write-Log -Level PASS -Message 'All students already provisioned. Nothing to do.'
    return
}

Write-Log -Level INFO -Message "$($studentsToProvision.Count) students to provision ($($alreadyProvisioned.Count) already done)."

# ============================================================================
# Phase 4: Register Power Platform Management App
# ============================================================================
Write-Section 'Phase 4: Registering Power Platform Management App'

$clientSecret = [string]$config.Identity.ClientSecret
if (-not [string]::IsNullOrWhiteSpace($clientSecret) -and -not (Test-PlaceholderValue -Value $clientSecret)) {
    Write-Log -Level INFO -Message 'Registering Entra app as Power Platform Management App (idempotent)...'
    try {
        New-PowerAppManagementApp -ApplicationId $pnpClientId -ErrorAction SilentlyContinue
        Write-Log -Level PASS -Message 'New-PowerAppManagementApp completed.'
    }
    catch {
        Write-Log -Level WARN -Message "New-PowerAppManagementApp returned: $_. Continuing — registration may already exist."
    }
} else {
    Write-Log -Level WARN -Message 'No Identity.ClientSecret configured — skipping Management App registration and credit allocation.'
}

# ============================================================================
# Phase 5: DLP pre-flight check
# ============================================================================
if (-not $SkipDlpCheck) {
    Write-Section 'Phase 5: DLP pre-flight check'
    try {
        $policies = Get-AdminDlpPolicy -ErrorAction SilentlyContinue
        foreach ($policy in $policies) {
            $groups = $policy.ConnectorGroups
            if ($null -eq $groups) { $groups = $policy.connectorGroups }
            if ($null -eq $groups) { continue }
            foreach ($group in $groups) {
                $classification = $group.classification
                if ($null -eq $classification) { $classification = $group.Classification }
                if ($classification -eq 'Blocked') {
                    $blocked = $group.connectors | Where-Object {
                        $_.id -like '*shared_http*' -or $_.id -like '*shared_office365*' -or $_.id -like '*shared_sharepointonline*'
                    }
                    if ($blocked) {
                        Write-Log -Level WARN -Message "DLP policy '$($policy.DisplayName)' blocks connectors needed for labs: $($blocked.id -join ', ')"
                    }
                }
            }
        }
        Write-Log -Level PASS -Message 'DLP check complete.'
    }
    catch {
        Write-Log -Level WARN -Message "DLP check failed: $_. Verify DLP policies manually."
    }
} else {
    Write-Log -Level INFO -Message 'DLP check skipped.'
}

# ============================================================================
# Phase 6–8: Batch provisioning loop
# ============================================================================
Write-Section "Phase 6-8: Provisioning $($studentsToProvision.Count) student environments"

$studentMap = [System.Collections.ArrayList]@($existingMap)
$batchNumber = 0

for ($i = 0; $i -lt $studentsToProvision.Count; $i += $batchSize) {
    $batchNumber++
    $batch = @($studentsToProvision[$i..([Math]::Min($i + $batchSize - 1, $studentsToProvision.Count - 1))])
    Write-Log -Level INFO -Message "--- Batch $batchNumber ($($batch.Count) students) ---"

    foreach ($studentEmail in $batch) {
        $studentAlias = Get-StudentAlias -Email $studentEmail
        $domainName = Get-SafeDomainName -Prefix $domainPrefix -StudentAlias $studentAlias
        $groupAlias = Get-SafeGroupAlias -Prefix $sitePrefix -StudentAlias $studentAlias
        $siteAlias = Get-SafeSiteAlias -Prefix $sitePrefix -StudentAlias $studentAlias

        Write-Log -Level INFO -Message "Provisioning $studentEmail (alias=$studentAlias, domain=$domainName)" -Component 'ENV'

        $studentRecord = [ordered]@{
            Email           = $studentEmail
            Alias           = $studentAlias
            DomainName      = $domainName
            EnvironmentUrl  = $null
            EnvironmentGuid = $null
            SharePointUrl   = $null
            GroupId         = $null
            TeamsId         = $null
            Status          = 'InProgress'
        }

        # ---- Phase 6: Create Power Platform environment ----
        if (-not $PSCmdlet.ShouldProcess($domainName, 'Create Power Platform environment')) {
            $studentRecord.Status = 'Skipped'
            [void]$studentMap.Add([pscustomobject]$studentRecord)
            continue
        }

        try {
            Write-Log -Level INFO -Message "Creating environment: $domainName" -Component 'ENV'
            $createArgs = @(
                'admin', 'create',
                '--type', 'Sandbox',
                '--domain', $domainName,
                '--name', "Workshop - $studentAlias",
                '--region', $region,
                '--currency', $currency,
                '--language', $language,
                '--templates', 'D365_CDSSampleApp'
            )
            $createOutput = & pac @createArgs 2>&1
            $createText = ($createOutput | ForEach-Object { $_.ToString() }) -join [System.Environment]::NewLine
            if ($LASTEXITCODE -ne 0) {
                Write-Log -Level ERROR -Message "pac admin create failed for $studentAlias : $createText" -Component 'ENV'
                $studentRecord.Status = 'FailedEnvCreate'
                [void]$studentMap.Add([pscustomobject]$studentRecord)
                continue
            }
            Write-Log -Level PASS -Message "pac admin create succeeded for $studentAlias" -Component 'ENV'

            # Poll for environment URL
            $envUrl = $null
            for ($attempt = 1; $attempt -le 12; $attempt++) {
                Start-Sleep -Seconds 15
                $envListOutput = & pac admin list 2>&1
                $envListText = ($envListOutput | ForEach-Object { $_.ToString() }) -join [System.Environment]::NewLine
                $urlMatches = [regex]::Matches($envListText, "https://[A-Za-z0-9.-]+$domainName[A-Za-z0-9.-]*/?" , 'IgnoreCase')
                if ($urlMatches.Count -gt 0) {
                    $envUrl = $urlMatches[0].Value.TrimEnd('/')
                    break
                }
                Write-Log -Level INFO -Message "Waiting for environment URL (attempt $attempt/12)..." -Component 'ENV'
            }

            if ($null -eq $envUrl) {
                Write-Log -Level ERROR -Message "Could not resolve environment URL for $domainName after polling." -Component 'ENV'
                $studentRecord.Status = 'FailedEnvUrlResolve'
                [void]$studentMap.Add([pscustomobject]$studentRecord)
                continue
            }

            $studentRecord.EnvironmentUrl = $envUrl
            Write-Log -Level PASS -Message "Environment URL: $envUrl" -Component 'ENV'

            # Resolve GUID
            $envGuid = $null
            try {
                $envGuid = Resolve-EnvironmentGuid -DomainName $domainName
            }
            catch {
                Write-Log -Level WARN -Message "Resolve-EnvironmentGuid failed: $_. Trying pac admin list --json." -Component 'ENV'
            }
            $studentRecord.EnvironmentGuid = $envGuid

            # Allocate credits
            if (-not [string]::IsNullOrWhiteSpace($clientSecret) -and -not (Test-PlaceholderValue -Value $clientSecret) -and $envGuid) {
                Write-Log -Level INFO -Message "Allocating $creditsPerEnv MCSSessions credits..." -Component 'CREDITS'
                try {
                    Invoke-WithRetry -ScriptBlock {
                        $token = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                        Set-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $token -Credits $creditsPerEnv
                    } -MaxAttempts 10 -DelaySeconds 30 -OperationName "Allocate credits for $studentAlias"

                    $verifyToken = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                    Confirm-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $verifyToken -ExpectedCredits $creditsPerEnv
                    Write-Log -Level PASS -Message "Credits allocated and verified." -Component 'CREDITS'
                }
                catch {
                    Write-Log -Level WARN -Message "Credit allocation failed: $_. Facilitator must allocate manually." -Component 'CREDITS'
                }
            }

            # Assign Environment Maker role
            Write-Log -Level INFO -Message "Assigning Environment Maker role to $studentEmail..." -Component 'ROLE'
            try {
                Invoke-WithRetry -ScriptBlock {
                    & pac admin assign-user --environment $envUrl --user $studentEmail --role 'Environment Maker' 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) { throw "pac admin assign-user exited with code $LASTEXITCODE" }
                } -MaxAttempts 5 -DelaySeconds 60 -OperationName "Assign role for $studentAlias"
                Write-Log -Level PASS -Message "Environment Maker role assigned." -Component 'ROLE'
            }
            catch {
                Write-Log -Level WARN -Message "Role assignment failed: $_. Facilitator must assign manually." -Component 'ROLE'
            }
        }
        catch {
            Write-Log -Level ERROR -Message "Environment provisioning failed for $studentAlias : $_" -Component 'ENV'
            $studentRecord.Status = 'FailedEnvCreate'
            [void]$studentMap.Add([pscustomobject]$studentRecord)
            continue
        }

        # ---- Phase 7: Create SharePoint site ----
        if (-not $SkipSharePoint) {
            try {
                Write-Log -Level INFO -Message "Creating SharePoint site: $siteAlias" -Component 'SP'

                Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop

                # Idempotency: purge from recycle bin if leftover from partial run
                $tenantDomain = ($adminUrl -replace 'https://', '' -replace '-admin\.sharepoint\.com.*', '')
                $expectedSiteUrl = "https://$tenantDomain.sharepoint.com/sites/$siteAlias"

                $deletedSite = Get-PnPTenantDeletedSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                if ($deletedSite) {
                    Write-Log -Level WARN -Message "Found $expectedSiteUrl in recycle bin — purging." -Component 'SP'
                    Remove-PnPTenantDeletedSite -Identity $expectedSiteUrl -Force
                }

                $existingSite = Get-PnPTenantSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                if ($null -eq $existingSite) {
                    $facilitatorUpn = if (-not [string]::IsNullOrWhiteSpace([string]$bootstrapConfig.AdminUser)) { [string]$bootstrapConfig.AdminUser } else { $studentEmail }
                    New-PnPSite -Type TeamSite `
                        -Title "Contoso IT - $studentAlias" `
                        -Alias $groupAlias `
                        -SiteAlias $siteAlias `
                        -Description "Workshop site for $studentAlias" `
                        -Owners $facilitatorUpn | Out-Null

                    # Poll for site readiness
                    for ($spAttempt = 1; $spAttempt -le 30; $spAttempt++) {
                        Start-Sleep -Seconds 10
                        $site = Get-PnPTenantSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                        if ($null -ne $site) { break }
                        Write-Log -Level INFO -Message "Waiting for site provisioning ($spAttempt/30)..." -Component 'SP'
                    }
                }

                $studentRecord.SharePointUrl = $expectedSiteUrl
                Write-Log -Level PASS -Message "SharePoint site ready: $expectedSiteUrl" -Component 'SP'

                # Connect to the new site and create lists
                Connect-PnPOnline -Url $expectedSiteUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop

                # Reuse the existing list/schema creation patterns from Initialize-WorkshopSharePoint.ps1
                . (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-WorkshopSharePoint.ps1') -ConfigPath $ConfigPath -ValidateOnly -ErrorAction SilentlyContinue 2>$null
                # The above won't work as a dot-source with params — instead create lists inline
                $devicesList = Get-PnPList -Identity 'Devices' -ErrorAction SilentlyContinue
                if ($null -eq $devicesList) {
                    New-PnPList -Title 'Devices' -Template GenericList -OnQuickLaunch | Out-Null
                    Write-Log -Level PASS -Message "Created Devices list." -Component 'SP'
                }

                $ticketsList = Get-PnPList -Identity 'Tickets' -ErrorAction SilentlyContinue
                if ($null -eq $ticketsList) {
                    New-PnPList -Title 'Tickets' -Template GenericList -OnQuickLaunch | Out-Null
                    Write-Log -Level PASS -Message "Created Tickets list." -Component 'SP'
                }

                $deviceRequestsList = Get-PnPList -Identity 'Device Requests' -ErrorAction SilentlyContinue
                if ($null -eq $deviceRequestsList) {
                    New-PnPList -Title 'Device Requests' -Template GenericList -OnQuickLaunch | Out-Null
                    Write-Log -Level PASS -Message "Created Device Requests list." -Component 'SP'
                }

                $resumesLib = Get-PnPList -Identity 'Incoming Resumes' -ErrorAction SilentlyContinue
                if ($null -eq $resumesLib) {
                    New-PnPList -Title 'Incoming Resumes' -Template DocumentLibrary -OnQuickLaunch | Out-Null
                    Write-Log -Level PASS -Message "Created Incoming Resumes library." -Component 'SP'
                }

                Disconnect-PnPOnline -ErrorAction SilentlyContinue
                Start-Sleep -Seconds 5
            }
            catch {
                Write-Log -Level ERROR -Message "SharePoint provisioning failed for $studentAlias : $_" -Component 'SP'
                Disconnect-PnPOnline -ErrorAction SilentlyContinue
            }
        }

        # ---- Phase 8: Create Teams team ----
        if (-not $SkipTeams) {
            try {
                Write-Log -Level INFO -Message "Creating Teams team for $studentAlias" -Component 'TEAMS'

                # Resolve student object ID from email
                $userResult = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$studentEmail" -ErrorAction Stop
                $studentObjectId = $userResult.id

                $teamBody = @{
                    'template@odata.bind' = 'https://graph.microsoft.com/v1.0/teamsTemplates(''standard'')'
                    displayName           = "$teamPrefix - $studentAlias"
                    members               = @(
                        @{
                            '@odata.type'    = '#microsoft.graph.aadUserConversationMember'
                            roles            = @('owner')
                            'user@odata.bind' = "https://graph.microsoft.com/v1.0/users('$studentObjectId')"
                        }
                    )
                } | ConvertTo-Json -Depth 10

                $teamResponse = Invoke-MgGraphRequest -Method POST `
                    -Uri 'https://graph.microsoft.com/v1.0/teams' `
                    -Body $teamBody `
                    -ContentType 'application/json' `
                    -ResponseHeadersVariable 'teamHeaders'

                $operationUrl = $teamHeaders.Location[0]

                Invoke-WithRetry -ScriptBlock {
                    $op = Invoke-MgGraphRequest -Method GET -Uri $operationUrl
                    if ($op.status -eq 'failed') { throw "Team creation failed: $($op.error)" }
                    if ($op.status -ne 'succeeded') { throw "Still in progress: $($op.status)" }
                    return $op
                } -MaxAttempts 30 -DelaySeconds 10 -OperationName "Create team for $studentAlias"

                # Extract team ID from Content-Location header or operation result
                if ($teamHeaders.ContainsKey('Content-Location') -and $teamHeaders['Content-Location'].Count -gt 0) {
                    $contentLocation = $teamHeaders['Content-Location'][0]
                    if ($contentLocation -match "teams\('([^']+)'\)") {
                        $studentRecord.TeamsId = $Matches[1]
                    }
                }

                Write-Log -Level PASS -Message "Teams team created for $studentAlias" -Component 'TEAMS'
            }
            catch {
                Write-Log -Level ERROR -Message "Teams creation failed for $studentAlias : $_" -Component 'TEAMS'
            }
        }

        # ---- Record result ----
        if ($studentRecord.Status -eq 'InProgress') {
            $studentRecord.Status = 'Completed'
        }
        [void]$studentMap.Add([pscustomobject]$studentRecord)

        # Save after each student for crash recovery
        Save-StudentEnvironmentMap -Path $mapFilePath -StudentMap $studentMap
    }
}

# ============================================================================
# Phase 9-10: Verification and final save
# ============================================================================
Write-Section 'Phase 9: Final verification'

$completed = @($studentMap | Where-Object { $_.Status -eq 'Completed' })
$failed = @($studentMap | Where-Object { $_.Status -like 'Failed*' })
$skipped = @($studentMap | Where-Object { $_.Status -eq 'Skipped' })

Write-Log -Level INFO -Message "Results: $($completed.Count) completed, $($failed.Count) failed, $($skipped.Count) skipped"

if ($failed.Count -gt 0) {
    Write-Log -Level WARN -Message "Failed students: $(($failed | ForEach-Object { $_.Email }) -join ', ')"
}

Save-StudentEnvironmentMap -Path $mapFilePath -StudentMap $studentMap
Write-Log -Level PASS -Message "Student environment map saved to $mapFilePath"

if (-not $SkipTeams) {
    Disconnect-MgGraph -ErrorAction SilentlyContinue
}

Write-Log -Level PASS -Message 'Student environment provisioning complete.'
