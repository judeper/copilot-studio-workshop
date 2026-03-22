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
$pnpLoginMode = if ([string]::IsNullOrWhiteSpace([string]$sharePointConfig.PnPLoginMode)) { 'OSLogin' } else { [string]$sharePointConfig.PnPLoginMode }
$pnpCertThumbprint = [string]$sharePointConfig.PnPCertificateThumbprint
$requiresAppOnlyCertificate = (-not $SkipSharePoint) -or (-not $SkipTeams)
if ($requiresAppOnlyCertificate) {
    if (Test-PlaceholderValue -Value $pnpCertThumbprint) {
        throw "SharePoint.PnPCertificateThumbprint is required for per-student provisioning. Re-run bootstrap to import or create a certificate and register it on the workshop app."
    }

    $pnpCertThumbprint = Get-RequiredString -Value $pnpCertThumbprint -Name 'SharePoint.PnPCertificateThumbprint'
    $provisioningCertificate = Get-CurrentUserCertificate -Thumbprint $pnpCertThumbprint
    if ($null -eq $provisioningCertificate) {
        throw "Certificate '$pnpCertThumbprint' was not found in Cert:\CurrentUser\My. Import or recreate it before running per-student provisioning."
    }

    if ($provisioningCertificate.NotAfter -le (Get-Date)) {
        throw "Certificate '$($provisioningCertificate.Thumbprint)' expired on $($provisioningCertificate.NotAfter.ToUniversalTime().ToString('u')). Re-run bootstrap to create a fresh certificate before provisioning students."
    }
}

$resolvedClientSecret = Resolve-ConfiguredClientSecret -Config $config
$clientSecret = [string]$resolvedClientSecret.Value

$teamsConfig = $config.Teams
$teamPrefix = if ($null -eq $teamsConfig -or [string]::IsNullOrWhiteSpace([string]$teamsConfig.StudentTeamPrefix)) { 'Contoso Recruiting' } else { [string]$teamsConfig.StudentTeamPrefix }

$mapFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'student-environment-map.json'

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

function Get-ConnectedPnPCurrentUserEmail {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $web = Get-PnPWeb -ErrorAction Stop
    $currentUser = Get-PnPProperty -ClientObject $web -Property CurrentUser
    $currentUserEmail = [string]$currentUser.Email
    if ([string]::IsNullOrWhiteSpace($currentUserEmail)) {
        throw "Connected successfully to $Label, but couldn't determine the delegated user's email address."
    }

    return $currentUserEmail
}

Write-Log -Level PASS -Message "Loaded config: $($participantEmails.Count) students, region=$region, credits=$creditsPerEnv, batch=$batchSize"
if ($requiresAppOnlyCertificate) {
    Write-Log -Level PASS -Message "Using app-only certificate '$($provisioningCertificate.Thumbprint)' (expires $($provisioningCertificate.NotAfter.ToUniversalTime().ToString('u')))."
}

if (-not [string]::IsNullOrWhiteSpace($clientSecret)) {
    $clientSecretSource = if ($resolvedClientSecret.Source -eq 'EnvironmentVariable') {
        "environment variable '$($resolvedClientSecret.EnvironmentVariableName)'"
    }
    else {
        'workshop-config.json'
    }
    Write-Log -Level PASS -Message "Client secret resolved from $clientSecretSource."
}

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
    if ([string]::IsNullOrWhiteSpace($clientSecret)) {
        Write-Log -Level WARN -Message 'No client secret is available — skipping PowerApps admin auth and DLP checks.'
        $SkipDlpCheck = $true
    }
    else {
        Write-Log -Level INFO -Message 'Authenticating PowerApps Admin module...'
        Add-PowerAppsAccount -TenantID $tenantId -ApplicationId $pnpClientId -ClientSecret $clientSecret -ErrorAction SilentlyContinue
        if (-not $?) {
            Write-Log -Level WARN -Message 'Add-PowerAppsAccount failed — DLP check will be skipped. Confirm the workshop app was registered with Power Platform once by a delegated admin, then verify DLP manually.'
            $SkipDlpCheck = $true
        }
        else {
            Write-Log -Level PASS -Message 'PowerApps Admin session established.'
        }
    }
}

if (-not $SkipSharePoint) {
    Require-Module -Name 'PnP.PowerShell'
    Write-Log -Level PASS -Message 'PnP.PowerShell module available.'
}

if (-not $SkipTeams) {
    Require-Module -Name 'Microsoft.Graph.Authentication'
    Write-Log -Level INFO -Message 'Connecting to Microsoft Graph (app-only, certificate)...'
    try {
        Connect-MgGraph -ClientId $pnpClientId -TenantId $tenantId -CertificateThumbprint $pnpCertThumbprint -ContextScope Process -NoWelcome
        Write-Log -Level PASS -Message 'Microsoft Graph session established.'
    }
    catch {
        throw "Microsoft Graph app-only auth failed with certificate '$pnpCertThumbprint'. Confirm the certificate is still in Cert:\CurrentUser\My and is registered on the workshop app. Details: $($_.Exception.Message)"
    }
}

# ============================================================================
# Phase 3: Pre-flight validation
# ============================================================================
Write-Section 'Phase 3: Pre-flight validation'

$existingMap = @(Read-StudentEnvironmentMap -Path $mapFilePath)
$completedExistingEntries = @($existingMap | Where-Object { [string]$_.Status -eq 'Completed' })
$retainedMapEntries = @($existingMap | Where-Object { [string]$_.Status -eq 'Completed' -or [string]$_.Status -eq 'Skipped' })
if ($existingMap.Count -gt 0) {
    Write-Log -Level WARN -Message "Found existing student map with $($existingMap.Count) entries. Completed entries will be skipped; failed entries can be retried."
}

$alreadyProvisioned = @{}
foreach ($entry in $retainedMapEntries) {
    if ($entry.Email) { $alreadyProvisioned[$entry.Email.ToLowerInvariant()] = $true }
}

$existingEntriesByEmail = @{}
foreach ($entry in $existingMap) {
    if ($entry.Email) {
        $existingEntriesByEmail[$entry.Email.ToLowerInvariant()] = $entry
    }
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

if (-not [string]::IsNullOrWhiteSpace($clientSecret) -and -not (Test-PlaceholderValue -Value $clientSecret)) {
    Write-Log -Level WARN -Message "Skipping New-PowerAppManagementApp in this app-only flow. Microsoft documents that a service principal can't register itself; a delegated Power Platform admin must register app '$pnpClientId' once with New-PowerAppManagementApp or pac admin application register."
} else {
    Write-Log -Level WARN -Message 'No client secret is available — skipping app-only PowerApps admin checks and preview credit allocation.'
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

$studentMap = [System.Collections.ArrayList]@($retainedMapEntries)
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

        $existingStudentRecord = $null
        $studentEmailKey = $studentEmail.ToLowerInvariant()
        if ($existingEntriesByEmail.ContainsKey($studentEmailKey)) {
            $existingStudentRecord = $existingEntriesByEmail[$studentEmailKey]
        }

        $studentRecord = [ordered]@{
            Email           = $studentEmail
            Alias           = $studentAlias
            DomainName      = $domainName
            EnvironmentUrl  = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.EnvironmentUrl } else { $null }
            EnvironmentGuid = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.EnvironmentGuid } else { $null }
            SharePointUrl   = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.SharePointUrl } else { $null }
            GroupId         = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.GroupId } else { $null }
            TeamsId         = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.TeamsId } else { $null }
            Status          = 'InProgress'
        }

        # ---- Phase 6: Create Power Platform environment ----
        if (-not $PSCmdlet.ShouldProcess($domainName, 'Create Power Platform environment')) {
            $studentRecord.Status = 'Skipped'
            [void]$studentMap.Add([pscustomobject]$studentRecord)
            continue
        }

        try {
            $existingEnvironment = $null
            try {
                $existingEnvironment = Find-PacEnvironmentByDomainName -DomainName $domainName
            }
            catch {
                Write-Log -Level WARN -Message "Initial environment lookup failed before create: $_" -Component 'ENV'
            }

            if ($null -eq $existingEnvironment) {
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
                    try {
                        $existingEnvironment = Find-PacEnvironmentByDomainName -DomainName $domainName
                    }
                    catch {
                        Write-Log -Level WARN -Message "Environment lookup after create failure also failed: $_" -Component 'ENV'
                    }

                    if ($null -eq $existingEnvironment) {
                        Write-Log -Level ERROR -Message "pac admin create failed for $studentAlias : $createText" -Component 'ENV'
                        $studentRecord.Status = 'FailedEnvCreate'
                        [void]$studentMap.Add([pscustomobject]$studentRecord)
                        continue
                    }

                    Write-Log -Level WARN -Message "pac admin create returned a non-zero exit code, but an environment for '$domainName' already exists. Reusing the existing environment." -Component 'ENV'
                }
                else {
                    Write-Log -Level PASS -Message "pac admin create succeeded for $studentAlias" -Component 'ENV'
                }
            }
            else {
                Write-Log -Level WARN -Message "Environment '$domainName' already exists. Reusing it for this provisioning run." -Component 'ENV'
            }

            # Poll for environment URL via pac admin list --json
            $resolvedEnvironment = $existingEnvironment
            for ($attempt = 1; $attempt -le 12 -and $null -eq $resolvedEnvironment; $attempt++) {
                Start-Sleep -Seconds 15
                try {
                    $resolvedEnvironment = Find-PacEnvironmentByDomainName -DomainName $domainName
                }
                catch {
                    Write-Log -Level WARN -Message "Environment lookup failed during polling attempt $attempt/12: $_" -Component 'ENV'
                }

                if ($null -eq $resolvedEnvironment) {
                    Write-Log -Level INFO -Message "Waiting for environment URL (attempt $attempt/12)..." -Component 'ENV'
                }
            }

            if ($null -eq $resolvedEnvironment -or [string]::IsNullOrWhiteSpace([string]$resolvedEnvironment.EnvironmentUrl)) {
                Write-Log -Level ERROR -Message "Could not resolve environment URL for $domainName after polling." -Component 'ENV'
                $studentRecord.Status = 'FailedEnvUrlResolve'
                [void]$studentMap.Add([pscustomobject]$studentRecord)
                continue
            }

            $envUrl = [string]$resolvedEnvironment.EnvironmentUrl
            $studentRecord.EnvironmentUrl = $envUrl.TrimEnd('/')
            Write-Log -Level PASS -Message "Environment URL: $($studentRecord.EnvironmentUrl)" -Component 'ENV'

            # Resolve GUID
            $envGuid = [string]$resolvedEnvironment.EnvironmentId
            if ([string]::IsNullOrWhiteSpace($envGuid)) {
                $envGuid = [string]$resolvedEnvironment.environmentId
            }
            if ([string]::IsNullOrWhiteSpace($envGuid)) {
                $envGuid = [string]$resolvedEnvironment.EnvironmentID
            }
            if ([string]::IsNullOrWhiteSpace($envGuid)) {
                try {
                    $envGuid = Resolve-EnvironmentGuid -DomainName $domainName
                }
                catch {
                    Write-Log -Level WARN -Message "Resolve-EnvironmentGuid failed after URL resolution: $_" -Component 'ENV'
                }
            }
            $studentRecord.EnvironmentGuid = $envGuid

            # Allocate credits
            if (-not [string]::IsNullOrWhiteSpace($clientSecret) -and -not (Test-PlaceholderValue -Value $clientSecret) -and $envGuid) {
                Write-Log -Level INFO -Message "Attempting preview app-only allocation of $creditsPerEnv MCSSessions credits..." -Component 'CREDITS'
                try {
                    Invoke-WithRetry -ScriptBlock {
                        $token = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                        Set-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $token -Credits $creditsPerEnv
                    } -MaxAttempts 10 -DelaySeconds 30 -OperationName "Allocate credits for $studentAlias" -NonRetryablePatterns @('403 \(Forbidden\)', 'StatusCode\s*:\s*403', 'Unauthorized')

                    $verifyToken = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                    Confirm-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $verifyToken -ExpectedCredits $creditsPerEnv
                    Write-Log -Level PASS -Message "Credits allocated and verified." -Component 'CREDITS'
                }
                catch {
                    Write-Log -Level WARN -Message "Credit allocation failed: $_. Microsoft currently documents Copilot credit allocation in Power Platform admin center, so the facilitator must allocate capacity manually." -Component 'CREDITS'
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

                $recordedSiteUrl = [string]$studentRecord.SharePointUrl
                if (-not [string]::IsNullOrWhiteSpace($recordedSiteUrl) -and $recordedSiteUrl -eq $expectedSiteUrl) {
                    Write-Log -Level INFO -Message "Reusing previously recorded SharePoint site '$expectedSiteUrl' for this retry." -Component 'SP'
                    $existingSite = [pscustomobject]@{ Url = $expectedSiteUrl }
                }
                else {
                    $existingSite = Get-PnPTenantSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                }
                if ($null -eq $existingSite) {
                    $facilitatorUpn = if (-not [string]::IsNullOrWhiteSpace([string]$bootstrapConfig.AdminUser)) { [string]$bootstrapConfig.AdminUser } else { $studentEmail }
                    $rootTenantUrl = "https://$tenantDomain.sharepoint.com"

                    try {
                        # Connect to root tenant URL — New-PnPSite calls SPSiteManager/create on the root site
                        Connect-PnPOnline -Url $rootTenantUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop
                        New-PnPSite -Type TeamSiteWithoutMicrosoft365Group `
                            -Title "Contoso IT - $studentAlias" `
                            -Url $expectedSiteUrl `
                            -Owner $facilitatorUpn `
                            -Description "Workshop site for $studentAlias" | Out-Null
                    }
                    catch {
                        Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop
                        Write-Log -Level WARN -Message "New-PnPSite failed: $($_.Exception.Message). Checking whether the site was created anyway..." -Component 'SP'

                        $siteCreatedAfterModernAttempt = $false
                        for ($modernProvisionAttempt = 1; $modernProvisionAttempt -le 6; $modernProvisionAttempt++) {
                            $siteAfterModernAttempt = Get-PnPTenantSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                            if ($null -ne $siteAfterModernAttempt) {
                                $siteCreatedAfterModernAttempt = $true
                                break
                            }

                            Start-Sleep -Seconds 5
                        }

                        if ($siteCreatedAfterModernAttempt) {
                            Write-Log -Level WARN -Message "New-PnPSite returned an error, but the site exists and provisioning will continue." -Component 'SP'
                        }
                        else {
                            Write-Log -Level WARN -Message "App-only SharePoint site creation was denied. Falling back to delegated sign-in using '$pnpLoginMode'." -Component 'SP'

                            $delegatedModernAttemptFailed = $false
                            try {
                                Connect-SharePointDelegatedWithFallback `
                                    -Url $rootTenantUrl `
                                    -TenantId $tenantId `
                                    -ClientId $pnpClientId `
                                    -LoginMode $pnpLoginMode `
                                    -Label 'the tenant root SharePoint site'

                                New-PnPSite -Type TeamSiteWithoutMicrosoft365Group `
                                    -Title "Contoso IT - $studentAlias" `
                                    -Url $expectedSiteUrl `
                                    -Owner $facilitatorUpn `
                                    -Description "Workshop site for $studentAlias" | Out-Null
                            }
                            catch {
                                $delegatedModernAttemptFailed = $true
                                Write-Log -Level WARN -Message "Delegated New-PnPSite failed: $($_.Exception.Message). Checking whether the site was created anyway..." -Component 'SP'
                            }

                            if ($delegatedModernAttemptFailed) {
                                Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop

                                $siteCreatedAfterDelegatedModernAttempt = $false
                                for ($delegatedModernProvisionAttempt = 1; $delegatedModernProvisionAttempt -le 6; $delegatedModernProvisionAttempt++) {
                                    $siteAfterDelegatedModernAttempt = Get-PnPTenantSite -Identity $expectedSiteUrl -ErrorAction SilentlyContinue
                                    if ($null -ne $siteAfterDelegatedModernAttempt) {
                                        $siteCreatedAfterDelegatedModernAttempt = $true
                                        break
                                    }

                                    Start-Sleep -Seconds 5
                                }

                                if ($siteCreatedAfterDelegatedModernAttempt) {
                                    Write-Log -Level WARN -Message "Delegated New-PnPSite returned an error, but the site exists and provisioning will continue." -Component 'SP'
                                }
                                else {
                                    Write-Log -Level WARN -Message 'Delegated New-PnPSite did not create the site. Trying delegated New-PnPTenantSite...' -Component 'SP'
                                    Connect-SharePointDelegatedWithFallback `
                                        -Url $adminUrl `
                                        -TenantId $tenantId `
                                        -ClientId $pnpClientId `
                                        -LoginMode $pnpLoginMode `
                                        -Label 'the SharePoint admin center'

                                    New-PnPTenantSite `
                                        -Title "Contoso IT - $studentAlias" `
                                        -Url $expectedSiteUrl `
                                        -Template 'STS#3' `
                                        -Owner $facilitatorUpn `
                                        -TimeZone 13 `
                                        -Wait
                                }
                            }
                        }
                    }

                    # Reconnect to admin URL for tenant-level polling
                    Connect-PnPOnline -Url $adminUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop

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

                # Connect to the new site and initialize full schema + sample data
                . (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-WorkshopSiteContent.ps1')

                $siteContentInitialized = $false
                try {
                    Connect-PnPOnline -Url $expectedSiteUrl -ClientId $pnpClientId -Tenant $tenantId -Thumbprint $pnpCertThumbprint -ErrorAction Stop
                    Initialize-WorkshopSiteContent -Config $config -CreateDeviceRequestsList $true -CreateIncomingResumesLibrary $true
                    $siteContentInitialized = $true
                }
                catch {
                    Write-Log -Level WARN -Message "App-only site-content initialization failed: $($_.Exception.Message). Falling back to delegated sign-in for site initialization." -Component 'SP'
                }
                finally {
                    Disconnect-PnPOnline -ErrorAction SilentlyContinue
                }

                if (-not $siteContentInitialized) {
                    try {
                        Connect-SharePointDelegatedWithFallback `
                            -Url $adminUrl `
                            -TenantId $tenantId `
                            -ClientId $pnpClientId `
                            -LoginMode $pnpLoginMode `
                            -Label 'the SharePoint admin center'

                        $delegatedAdminUpn = Get-ConnectedPnPCurrentUserEmail -Label 'the SharePoint admin center'
                        $siteCollectionAdmins = @($studentEmail, $delegatedAdminUpn) |
                            Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
                            Select-Object -Unique

                        Write-Log -Level INFO -Message "Granting site collection admin access to $($siteCollectionAdmins -join ', ') before retrying site initialization." -Component 'SP'
                        Set-PnPTenantSite -Identity $expectedSiteUrl -Owners $siteCollectionAdmins -Wait -ErrorAction Stop
                    }
                    finally {
                        try {
                            Disconnect-PnPOnline -ErrorAction Stop
                        }
                        catch {
                        }
                    }

                    Connect-SharePointDelegatedWithFallback `
                        -Url $expectedSiteUrl `
                        -TenantId $tenantId `
                        -ClientId $pnpClientId `
                        -LoginMode $pnpLoginMode `
                        -Label "the student SharePoint site '$expectedSiteUrl'"

                    try {
                        Initialize-WorkshopSiteContent -Config $config -CreateDeviceRequestsList $true -CreateIncomingResumesLibrary $true
                    }
                    finally {
                        try {
                            Disconnect-PnPOnline -ErrorAction Stop
                        }
                        catch {
                        }
                    }
                }

                Start-Sleep -Seconds 5
            }
            catch {
                Write-Log -Level ERROR -Message "SharePoint provisioning failed for $studentAlias : $_" -Component 'SP'
                if ($studentRecord.Status -eq 'InProgress') {
                    $studentRecord.Status = 'FailedSharePoint'
                }
                try {
                    Disconnect-PnPOnline -ErrorAction Stop
                }
                catch {
                }
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
                if ($studentRecord.Status -eq 'InProgress') {
                    $studentRecord.Status = 'FailedTeams'
                }
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
