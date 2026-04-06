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
$sitePrefix = if ([string]::IsNullOrWhiteSpace([string]$sharePointConfig.SitePrefix)) { 'WoodgroveBank' } else { [string]$sharePointConfig.SitePrefix }
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
$teamPrefix = if ($null -eq $teamsConfig -or [string]::IsNullOrWhiteSpace([string]$teamsConfig.StudentTeamPrefix)) { 'Woodgrove Lending' } else { [string]$teamsConfig.StudentTeamPrefix }

$mapFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'student-environment-map.json'
$canAttemptCreditAllocation = (-not [string]::IsNullOrWhiteSpace($clientSecret)) -and (-not (Test-PlaceholderValue -Value $clientSecret))

function Add-StudentManualFollowUp {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$StudentRecord,

        [Parameter(Mandatory = $true)]
        [string]$Action
    )

    if (-not $StudentRecord.Contains('ManualFollowUp')) {
        $StudentRecord.ManualFollowUp = [System.Collections.Generic.List[string]]::new()
    }

    if (-not $StudentRecord.ManualFollowUp.Contains($Action)) {
        $StudentRecord.ManualFollowUp.Add($Action)
    }
}

function Complete-StudentProvisioningRecord {
    param(
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$StudentRecord
    )

    if ($StudentRecord.Status -ne 'InProgress') {
        return
    }

    $manualFollowUpCount = @($StudentRecord.ManualFollowUp).Count
    if ($manualFollowUpCount -gt 0) {
        $StudentRecord.Status = 'FollowUpRequired'
        Write-Log -Level WARN -Message "Provisioning finished for $($StudentRecord.Alias), but manual follow-up is still required: $((@($StudentRecord.ManualFollowUp)) -join '; ')" -Component 'SUMMARY'
        return
    }

    $StudentRecord.Status = 'Completed'
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

function Invoke-StudentTeamsProvisioningInIsolatedProcess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$Thumbprint,

        [Parameter(Mandatory = $true)]
        [string]$StudentEmail,

        [Parameter(Mandatory = $true)]
        [string]$TeamDisplayName
    )

    $pwshCommand = Get-Command -Name 'pwsh' -ErrorAction Stop
    $childScriptTemplate = @'
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Import-Module Microsoft.Graph.Authentication -Force

$tenantId = '__TENANT_ID__'
$clientId = '__CLIENT_ID__'
$thumbprint = '__THUMBPRINT__'
$studentEmail = '__STUDENT_EMAIL__'
$teamDisplayName = '__TEAM_DISPLAY_NAME__'

Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateThumbprint $thumbprint -ContextScope Process -NoWelcome | Out-Null

try {
    $filterDisplayName = $teamDisplayName.Replace("'", "''")
    $existingGroupResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$filterDisplayName'&`$select=id,displayName,resourceProvisioningOptions" -ErrorAction Stop
    $existingTeam = @($existingGroupResponse.value | Where-Object { @($_.resourceProvisioningOptions) -contains 'Team' }) | Select-Object -First 1
    if ($null -ne $existingTeam -and -not [string]::IsNullOrWhiteSpace([string]$existingTeam.id)) {
        Write-Output ('RESULT_JSON:' + (@{
            TeamId = [string]$existingTeam.id
            GroupId = [string]$existingTeam.id
            Reused = $true
        } | ConvertTo-Json -Compress))
        return
    }

    $escapedStudentEmail = [uri]::EscapeDataString($studentEmail)
    $userResult = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/${escapedStudentEmail}?`$select=id,userPrincipalName" -ErrorAction Stop
    $studentObjectId = [string]$userResult.id
    if ([string]::IsNullOrWhiteSpace($studentObjectId)) {
        throw "Microsoft Graph did not return an id for '$studentEmail'."
    }

    $teamBody = @{
        'template@odata.bind' = 'https://graph.microsoft.com/v1.0/teamsTemplates(''standard'')'
        displayName           = $teamDisplayName
        members               = @(
            @{
                '@odata.type'     = '#microsoft.graph.aadUserConversationMember'
                roles             = @('owner')
                'user@odata.bind' = "https://graph.microsoft.com/v1.0/users('$studentObjectId')"
            }
        )
    } | ConvertTo-Json -Depth 10

    Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/v1.0/teams' -Body $teamBody -ContentType 'application/json' -ResponseHeadersVariable 'teamHeaders' -ErrorAction Stop | Out-Null

    $operationUrl = $null
    if ($teamHeaders.ContainsKey('Location') -and $teamHeaders['Location'].Count -gt 0) {
        $operationUrl = [string]$teamHeaders['Location'][0]
    }
    if ([string]::IsNullOrWhiteSpace($operationUrl)) {
        throw 'Microsoft Graph did not return a Location header for team creation.'
    }
    if ($operationUrl -notmatch '^https://') {
        $operationUrl = 'https://graph.microsoft.com/v1.0/' + $operationUrl.TrimStart('/')
    }
    elseif ($operationUrl -match '^https://graph\.microsoft\.com/(?!(v1\.0|beta)/)') {
        $operationUrl = $operationUrl -replace '^https://graph\.microsoft\.com/?', 'https://graph.microsoft.com/v1.0/'
    }

    $teamId = $null
    if ($teamHeaders.ContainsKey('Content-Location') -and $teamHeaders['Content-Location'].Count -gt 0) {
        $contentLocation = [string]$teamHeaders['Content-Location'][0]
        if ($contentLocation -match "teams\('([^']+)'\)") {
            $teamId = $Matches[1]
        }
    }

    $operationResult = $null
    for ($attempt = 1; $attempt -le 30; $attempt++) {
        Start-Sleep -Seconds 10
        $operationResult = Invoke-MgGraphRequest -Method GET -Uri $operationUrl -ErrorAction Stop
        if ([string]$operationResult.status -eq 'failed') {
            throw "Team creation failed: $($operationResult | ConvertTo-Json -Depth 10 -Compress)"
        }
        if ([string]$operationResult.status -eq 'succeeded') {
            break
        }
    }

    if ($null -eq $operationResult -or [string]$operationResult.status -ne 'succeeded') {
        throw 'Team creation did not reach succeeded state within the retry window.'
    }

    if ([string]::IsNullOrWhiteSpace($teamId)) {
        foreach ($locationProperty in @('targetResourceLocation', 'resourceLocation')) {
            if ($operationResult.PSObject.Properties.Name -contains $locationProperty) {
                $candidateLocation = [string]$operationResult.$locationProperty
                if ($candidateLocation -match "teams\('([^']+)'\)") {
                    $teamId = $Matches[1]
                    break
                }
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($teamId)) {
        $groupResponse = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$filterDisplayName'&`$select=id,displayName,resourceProvisioningOptions" -ErrorAction Stop
        $matchingTeam = @($groupResponse.value | Where-Object { @($_.resourceProvisioningOptions) -contains 'Team' }) | Select-Object -First 1
        if ($null -ne $matchingTeam -and -not [string]::IsNullOrWhiteSpace([string]$matchingTeam.id)) {
            $teamId = [string]$matchingTeam.id
        }
    }

    if ([string]::IsNullOrWhiteSpace($teamId)) {
        throw 'Team creation succeeded but no team id could be resolved.'
    }

    Write-Output ('RESULT_JSON:' + (@{
        TeamId = $teamId
        GroupId = $teamId
        Reused = $false
    } | ConvertTo-Json -Compress))
}
finally {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}
'@

    $childScript = $childScriptTemplate.
        Replace('__TENANT_ID__', $TenantId.Replace("'", "''")).
        Replace('__CLIENT_ID__', $ClientId.Replace("'", "''")).
        Replace('__THUMBPRINT__', $Thumbprint.Replace("'", "''")).
        Replace('__STUDENT_EMAIL__', $StudentEmail.Replace("'", "''")).
        Replace('__TEAM_DISPLAY_NAME__', $TeamDisplayName.Replace("'", "''"))

    $encodedChildScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($childScript))
    $commandOutput = & $pwshCommand.Source -NoProfile -EncodedCommand $encodedChildScript 2>&1
    $outputLines = @($commandOutput | ForEach-Object { $_.ToString() })
    $outputText = ($outputLines -join [System.Environment]::NewLine).Trim()

    if ($LASTEXITCODE -ne 0) {
        throw "Isolated Teams provisioning failed: $outputText"
    }

    $resultLine = $outputLines | Where-Object { $_ -like 'RESULT_JSON:*' } | Select-Object -Last 1
    if ([string]::IsNullOrWhiteSpace([string]$resultLine)) {
        throw "Isolated Teams provisioning returned no structured result. Output: $outputText"
    }

    $resultJson = $resultLine.Substring('RESULT_JSON:'.Length)
    return ($resultJson | ConvertFrom-Json -Depth 10)
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

if (-not $SkipTeams) {
    Require-Module -Name 'Microsoft.Graph.Authentication'
    Write-Log -Level INFO -Message 'Connecting to Microsoft Graph (app-only, certificate)...'
    try {
        Connect-MgGraph -ClientId $pnpClientId -TenantId $tenantId -CertificateThumbprint $pnpCertThumbprint -ContextScope Process -NoWelcome | Out-Null
        Write-Log -Level PASS -Message 'Microsoft Graph session established.'
    }
    catch {
        throw "Microsoft Graph app-only auth failed with certificate '$pnpCertThumbprint'. Confirm the certificate is still in Cert:\CurrentUser\My and is registered on the workshop app. Details: $($_.Exception.Message)"
    }
    finally {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
    }
}

if (-not $SkipSharePoint) {
    # Connect to Graph before importing PnP.PowerShell to avoid the local MSAL assembly conflict
    # that breaks certificate-based Graph auth after PnP is loaded into the current process.
    Require-Module -Name 'PnP.PowerShell'
    Write-Log -Level PASS -Message 'PnP.PowerShell module available.'
}

# ============================================================================
# Phase 3: Pre-flight validation
# ============================================================================
Write-Section 'Phase 3: Pre-flight validation'

$existingMap = @(Read-StudentEnvironmentMap -Path $mapFilePath)
$completedExistingEntries = @($existingMap | Where-Object { [string]$_.Status -eq 'Completed' })
$retainedMapEntries = @(
    $existingMap | Where-Object {
        $entryStatus = [string]$_.Status
        if ($entryStatus -eq 'Skipped') {
            return $true
        }

        if ($entryStatus -ne 'Completed') {
            return $false
        }

        if (-not $SkipSharePoint -and [string]::IsNullOrWhiteSpace([string]$_.SharePointUrl)) {
            return $false
        }

        if (-not $SkipTeams -and [string]::IsNullOrWhiteSpace([string]$_.TeamsId)) {
            return $false
        }

        return $true
    }
)
if ($existingMap.Count -gt 0) {
    Write-Log -Level WARN -Message "Found existing student map with $($existingMap.Count) entries. Completed entries with all required artifacts will be skipped; failed or follow-up-required entries can be retried."
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

if ($canAttemptCreditAllocation) {
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
            Email                  = $studentEmail
            Alias                  = $studentAlias
            DomainName             = $domainName
            EnvironmentUrl         = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.EnvironmentUrl } else { $null }
            EnvironmentGuid        = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.EnvironmentGuid } else { $null }
            SharePointUrl          = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.SharePointUrl } else { $null }
            GroupId                = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.GroupId } else { $null }
            TeamsId                = if ($null -ne $existingStudentRecord) { [string]$existingStudentRecord.TeamsId } else { $null }
            CreditAllocationStatus = 'Pending'
            RoleAssignmentStatus   = 'Pending'
            ManualFollowUp         = [System.Collections.Generic.List[string]]::new()
            Status                 = 'InProgress'
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
            if ($canAttemptCreditAllocation -and $envGuid) {
                Write-Log -Level INFO -Message "Attempting preview app-only allocation of $creditsPerEnv MCSSessions credits..." -Component 'CREDITS'
                try {
                    Invoke-WithRetry -ScriptBlock {
                        $token = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                        Set-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $token -Credits $creditsPerEnv
                    } -MaxAttempts 10 -DelaySeconds 30 -OperationName "Allocate credits for $studentAlias" -NonRetryablePatterns @('403 \(Forbidden\)', 'StatusCode\s*:\s*403', 'Unauthorized')

                    $verifyToken = Get-PowerPlatformAccessToken -TenantId $tenantId -ClientId $pnpClientId -ClientSecret $clientSecret
                    Confirm-EnvironmentCopilotCredits -EnvironmentGuid $envGuid -AccessToken $verifyToken -ExpectedCredits $creditsPerEnv
                    $studentRecord.CreditAllocationStatus = 'Allocated'
                    Write-Log -Level PASS -Message "Credits allocated and verified." -Component 'CREDITS'
                }
                catch {
                    $studentRecord.CreditAllocationStatus = 'ManualRequired'
                    Add-StudentManualFollowUp -StudentRecord $studentRecord -Action 'Allocate Copilot Studio credits manually in the Power Platform admin center.'
                    Write-Log -Level WARN -Message "Credit allocation failed: $_. Microsoft currently documents Copilot credit allocation in Power Platform admin center, so the facilitator must allocate capacity manually." -Component 'CREDITS'
                }
            }
            else {
                $studentRecord.CreditAllocationStatus = 'ManualRequired'
                if (-not $canAttemptCreditAllocation) {
                    Add-StudentManualFollowUp -StudentRecord $studentRecord -Action 'Allocate Copilot Studio credits manually in the Power Platform admin center because app-only credit allocation is not configured.'
                    Write-Log -Level WARN -Message 'Credit allocation was not attempted because no client secret is configured for app-only licensing calls. Manual allocation is still required.' -Component 'CREDITS'
                }
                elseif (-not $envGuid) {
                    Add-StudentManualFollowUp -StudentRecord $studentRecord -Action 'Allocate Copilot Studio credits manually, or rerun after the environment GUID resolves.'
                    Write-Log -Level WARN -Message "Credit allocation was not attempted because the environment GUID could not be resolved for $studentAlias. Manual allocation or a later rerun is required." -Component 'CREDITS'
                }
            }

            # Assign Environment Maker role
            Write-Log -Level INFO -Message "Assigning Environment Maker role to $studentEmail..." -Component 'ROLE'
            try {
                Invoke-WithRetry -ScriptBlock {
                    & pac admin assign-user --environment $envUrl --user $studentEmail --role 'Environment Maker' 2>&1 | Out-Null
                    if ($LASTEXITCODE -ne 0) { throw "pac admin assign-user exited with code $LASTEXITCODE" }
                } -MaxAttempts 5 -DelaySeconds 60 -OperationName "Assign role for $studentAlias"
                $studentRecord.RoleAssignmentStatus = 'Assigned'
                Write-Log -Level PASS -Message "Environment Maker role assigned." -Component 'ROLE'
            }
            catch {
                $studentRecord.RoleAssignmentStatus = 'ManualRequired'
                Add-StudentManualFollowUp -StudentRecord $studentRecord -Action 'Assign the student to the Environment Maker role manually.'
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
                            -Title "Woodgrove Bank - $studentAlias" `
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
                                    -Title "Woodgrove Bank - $studentAlias" `
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
                                        -Title "Woodgrove Bank - $studentAlias" `
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
                $teamResult = Invoke-StudentTeamsProvisioningInIsolatedProcess `
                    -TenantId $tenantId `
                    -ClientId $pnpClientId `
                    -Thumbprint $pnpCertThumbprint `
                    -StudentEmail $studentEmail `
                    -TeamDisplayName "$teamPrefix - $studentAlias"

                $studentRecord.TeamsId = [string]$teamResult.TeamId
                if (-not [string]::IsNullOrWhiteSpace([string]$teamResult.GroupId)) {
                    $studentRecord.GroupId = [string]$teamResult.GroupId
                }

                $teamVerb = if ([bool]$teamResult.Reused) { 'reused' } else { 'created' }
                Write-Log -Level PASS -Message "Teams team $teamVerb for $studentAlias (id=$($studentRecord.TeamsId))" -Component 'TEAMS'
            }
            catch {
                Write-Log -Level ERROR -Message "Teams creation failed for $studentAlias : $_" -Component 'TEAMS'
                if ($studentRecord.Status -eq 'InProgress') {
                    $studentRecord.Status = 'FailedTeams'
                }
            }
        }

        # ---- Record result ----
        Complete-StudentProvisioningRecord -StudentRecord $studentRecord
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
$followUpRequired = @($studentMap | Where-Object { $_.Status -eq 'FollowUpRequired' })
$failed = @($studentMap | Where-Object { $_.Status -like 'Failed*' })
$skipped = @($studentMap | Where-Object { $_.Status -eq 'Skipped' })

Write-Log -Level INFO -Message "Results: $($completed.Count) completed, $($followUpRequired.Count) need follow-up, $($failed.Count) failed, $($skipped.Count) skipped"

if ($failed.Count -gt 0) {
    Write-Log -Level WARN -Message "Failed students: $(($failed | ForEach-Object { $_.Email }) -join ', ')"
}

if ($followUpRequired.Count -gt 0) {
    foreach ($entry in $followUpRequired) {
        $manualActions = @($entry.ManualFollowUp)
        $manualActionsText = if ($manualActions.Count -gt 0) { $manualActions -join '; ' } else { 'Review the student record for manual follow-up.' }
        Write-Log -Level WARN -Message "Manual follow-up required for $($entry.Email): $manualActionsText"
    }
}

Save-StudentEnvironmentMap -Path $mapFilePath -StudentMap $studentMap
Write-Log -Level PASS -Message "Student environment map saved to $mapFilePath"

if (-not $SkipTeams) {
    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
}

if ($followUpRequired.Count -gt 0) {
    Write-Log -Level WARN -Message 'Student environment provisioning completed with manual follow-up still required for one or more students.'
} else {
    Write-Log -Level PASS -Message 'Student environment provisioning complete.'
}
