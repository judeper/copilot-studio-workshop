Set-StrictMode -Version Latest

$script:LogFilePath = $null

function Initialize-WorkshopLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ScriptName,

        [Parameter()]
        [string]$LogDirectory
    )

    if ([string]::IsNullOrWhiteSpace($LogDirectory)) {
        $LogDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'logs'
    }

    if (-not (Test-Path -LiteralPath $LogDirectory -PathType Container)) {
        New-Item -Path $LogDirectory -ItemType Directory -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $script:LogFilePath = Join-Path -Path $LogDirectory -ChildPath "$ScriptName-$timestamp.log"
}

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('INFO', 'WARN', 'ERROR', 'PASS')]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [string]$Component = ''
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $prefix = if ($Component) { "[$Level][$Component]" } else { "[$Level]" }
    $line = "$timestamp $prefix $Message"

    if ($script:LogFilePath) {
        Add-Content -LiteralPath $script:LogFilePath -Value $line -Encoding UTF8
    }

    $foregroundColor = switch ($Level) {
        'PASS'  { 'Green' }
        'WARN'  { 'Yellow' }
        'ERROR' { 'Red' }
        'INFO'  { 'Cyan' }
    }

    Write-Host $line -ForegroundColor $foregroundColor
}

function Write-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host "`n== $Message ==" -ForegroundColor Cyan
}

function Write-StepResult {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('PASS', 'WARN', 'INFO')]
        [string]$Level,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $foregroundColor = switch ($Level) {
        'PASS' { 'Green' }
        'WARN' { 'Yellow' }
        'INFO' { 'Cyan' }
    }

    Write-Host "[$Level] $Message" -ForegroundColor $foregroundColor
}

function Get-WorkshopConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        $examplePath = Join-Path -Path (Split-Path -Path $Path -Parent) -ChildPath 'workshop-config.example.json'
        if (Test-Path -LiteralPath $examplePath -PathType Leaf) {
            throw "Config file '$Path' was not found. Copy '$examplePath' to '$Path' and replace the placeholder values before running this script."
        }

        throw "Config file '$Path' was not found."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100
}

function Get-ConfigDirectory {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    $resolvedConfigPath = (Resolve-Path -LiteralPath $ConfigPath).Path
    return Split-Path -Path $resolvedConfigPath -Parent
}

function Test-PlaceholderValue {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $true
    }

    return $Value -match '<[^>]+>'
}

function Get-RequiredString {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Config value '$Name' is required."
    }

    if (Test-PlaceholderValue -Value $Value) {
        throw "Config value '$Name' still contains a placeholder value: $Value"
    }

    return $Value
}

function Assert-FacilitatorOnlyEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter()]
        [string[]]$AllowedPurposes = @('FacilitatorDemo', 'Fallback')
    )

    $purpose = $null
    if ($Config -and $Config.PSObject.Properties.Name -contains 'Workshop' -and $Config.Workshop) {
        if ($Config.Workshop.PSObject.Properties.Name -contains 'EnvironmentPurpose') {
            $purpose = [string]$Config.Workshop.EnvironmentPurpose
        }
    }

    if ([string]::IsNullOrWhiteSpace($purpose) -or (Test-PlaceholderValue -Value $purpose)) {
        throw "Workshop.EnvironmentPurpose is not set in config. This script is facilitator-only. Set EnvironmentPurpose to one of: $($AllowedPurposes -join ', ') in workshop-config.json before running."
    }

    if ($purpose -notin $AllowedPurposes) {
        throw "Workshop.EnvironmentPurpose is '$purpose' but this script requires one of: $($AllowedPurposes -join ', '). Refusing to run to protect non-facilitator environments."
    }

    Write-Log -Level INFO -Message "EnvironmentPurpose check passed: $purpose"
}

function Get-OptionalConfigString {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [object]$Value
    )

    if ($null -eq $Value) {
        return ''
    }

    return ([string]$Value).Trim()
}

function Save-WorkshopConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    $resolvedDirectory = Get-ConfigDirectory -ConfigPath $Path
    if (-not (Test-Path -LiteralPath $resolvedDirectory -PathType Container)) {
        throw "Config directory '$resolvedDirectory' was not found."
    }

    $Config | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Resolve-ConfiguredPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ConfiguredPath
    )

    if ([string]::IsNullOrWhiteSpace($ConfiguredPath)) {
        return $null
    }

    if ([System.IO.Path]::IsPathRooted($ConfiguredPath)) {
        return [System.IO.Path]::GetFullPath($ConfiguredPath)
    }

    $configDirectory = Get-ConfigDirectory -ConfigPath $ConfigPath
    return [System.IO.Path]::GetFullPath((Join-Path -Path $configDirectory -ChildPath $ConfiguredPath))
}

function Assert-FileExists {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        throw "$Label path is required."
    }

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label file was not found at '$Path'."
    }

    return (Resolve-Path -LiteralPath $Path).Path
}

function Get-CurrentUserCertificate {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Thumbprint
    )

    if ([string]::IsNullOrWhiteSpace($Thumbprint)) {
        return $null
    }

    $normalizedThumbprint = ($Thumbprint -replace '\s', '').ToUpperInvariant()
    return Get-ChildItem -Path 'Cert:\CurrentUser\My' -ErrorAction SilentlyContinue |
        Where-Object { $_.Thumbprint.ToUpperInvariant() -eq $normalizedThumbprint } |
        Sort-Object -Property NotAfter -Descending |
        Select-Object -First 1
}

function New-WorkshopSelfSignedCertificate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CommonName,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$FriendlyName,

        [Parameter()]
        [int]$ValidityYears = 2
    )

    if ([string]::IsNullOrWhiteSpace($FriendlyName)) {
        $FriendlyName = $CommonName
    }

    $subject = if ($CommonName -like 'CN=*') { $CommonName } else { "CN=$CommonName" }
    return New-SelfSignedCertificate `
        -CertStoreLocation 'Cert:\CurrentUser\My' `
        -Subject $subject `
        -FriendlyName $FriendlyName `
        -KeyAlgorithm RSA `
        -KeyLength 2048 `
        -HashAlgorithm SHA256 `
        -KeyExportPolicy Exportable `
        -KeySpec Signature `
        -NotAfter (Get-Date).AddYears($ValidityYears)
}

function Resolve-ConfiguredClientSecret {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    $clientSecret = [string]$Config.Identity.ClientSecret
    if (-not [string]::IsNullOrWhiteSpace($clientSecret) -and -not (Test-PlaceholderValue -Value $clientSecret)) {
        return [pscustomobject]@{
            Value                   = $clientSecret
            Source                  = 'Config'
            EnvironmentVariableName = $null
        }
    }

    $envVarName = [string]$Config.Identity.ClientSecretEnvVar
    if (-not [string]::IsNullOrWhiteSpace($envVarName) -and -not (Test-PlaceholderValue -Value $envVarName)) {
        $envValue = [Environment]::GetEnvironmentVariable($envVarName, 'Process')
        if ([string]::IsNullOrWhiteSpace($envValue)) {
            $envValue = [Environment]::GetEnvironmentVariable($envVarName, 'User')
        }

        if (-not [string]::IsNullOrWhiteSpace($envValue)) {
            return [pscustomobject]@{
                Value                   = $envValue
                Source                  = 'EnvironmentVariable'
                EnvironmentVariableName = $envVarName
            }
        }
    }

    $resolvedEnvVarName = if ([string]::IsNullOrWhiteSpace($envVarName)) { $null } else { $envVarName }
    return [pscustomobject]@{
        Value                   = $null
        Source                  = $null
        EnvironmentVariableName = $resolvedEnvVarName
    }
}

function Set-UserEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    [Environment]::SetEnvironmentVariable($Name, $Value, 'User')
    [Environment]::SetEnvironmentVariable($Name, $Value, 'Process')
    Set-Item -Path "Env:$Name" -Value $Value
}

function Test-AppOnlyCertificateReadiness {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Thumbprint,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$GraphProbeUserPrincipalName,

        [Parameter(Mandatory = $true)]
        [string]$SharePointAdminUrl
    )

    $result = [ordered]@{
        Thumbprint          = $Thumbprint
        CertificateFound    = $false
        CertificateExpired  = $false
        Certificate         = $null
        GraphConnected      = $false
        GraphProbeSucceeded = $false
        GraphProbeUser      = $GraphProbeUserPrincipalName
        SharePointConnected = $false
        Errors              = [System.Collections.ArrayList]@()
    }

    if (Test-PlaceholderValue -Value $Thumbprint) {
        [void]$result.Errors.Add('No certificate thumbprint is configured.')
        return [pscustomobject]$result
    }

    $certificate = Get-CurrentUserCertificate -Thumbprint $Thumbprint
    if ($null -eq $certificate) {
        [void]$result.Errors.Add("Certificate '$Thumbprint' was not found in Cert:\CurrentUser\My.")
        return [pscustomobject]$result
    }

    $result.CertificateFound = $true
    $result.Certificate = $certificate

    if ($certificate.NotAfter -le (Get-Date)) {
        $result.CertificateExpired = $true
        [void]$result.Errors.Add("Certificate '$($certificate.Thumbprint)' expired on $($certificate.NotAfter.ToUniversalTime().ToString('u')).")
        return [pscustomobject]$result
    }

    try {
        try {
            Disconnect-MgGraph -ErrorAction Stop | Out-Null
        }
        catch {
        }
        Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -CertificateThumbprint $certificate.Thumbprint -ContextScope Process -NoWelcome | Out-Null
        $result.GraphConnected = $true
    }
    catch {
        [void]$result.Errors.Add("Graph app-only auth failed: $($_.Exception.Message)")
    }
    finally {
        try {
            Disconnect-MgGraph -ErrorAction Stop | Out-Null
        }
        catch {
        }
    }

    if ($result.GraphConnected -and -not [string]::IsNullOrWhiteSpace($GraphProbeUserPrincipalName)) {
        try {
            Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -CertificateThumbprint $certificate.Thumbprint -ContextScope Process -NoWelcome | Out-Null
            Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/${GraphProbeUserPrincipalName}?`$select=id,userPrincipalName" -ErrorAction Stop | Out-Null
            $result.GraphProbeSucceeded = $true
        }
        catch {
            [void]$result.Errors.Add("Graph user lookup failed for '$GraphProbeUserPrincipalName': $($_.Exception.Message)")
        }
        finally {
            try {
                Disconnect-MgGraph -ErrorAction Stop | Out-Null
            }
            catch {
            }
        }
    }

    try {
        Connect-PnPOnline -Url $SharePointAdminUrl -ClientId $ClientId -Tenant $TenantId -Thumbprint $certificate.Thumbprint -ErrorAction Stop
        $result.SharePointConnected = $true
    }
    catch {
        [void]$result.Errors.Add("SharePoint app-only auth failed: $($_.Exception.Message)")
    }
    finally {
        try {
            Disconnect-PnPOnline -ErrorAction Stop
        }
        catch {
        }
    }

    return [pscustomobject]$result
}

function Require-Module {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Module -ListAvailable -Name $Name)) {
        throw "Required PowerShell module '$Name' is not installed."
    }

    Import-Module -Name $Name -ErrorAction Stop | Out-Null
}

function Require-Command {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if (-not (Get-Command -Name $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' is not available on PATH."
    }
}

function Invoke-NativeCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    & $FilePath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$FailureMessage (exit code $LASTEXITCODE)."
    }
}

function Invoke-NativeCommandWithOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    $output = & $FilePath @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $text = ($output | ForEach-Object { $_.ToString() }) -join [System.Environment]::NewLine

    if ($exitCode -ne 0) {
        if (-not [string]::IsNullOrWhiteSpace($text)) {
            throw "$FailureMessage`n$text"
        }

        throw $FailureMessage
    }

    return $text
}

function Get-StudentAlias {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Email
    )

    $alias = ($Email -split '@')[0]
    return $alias.Trim().ToLowerInvariant()
}

function Get-SafeGroupAlias {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [Parameter(Mandatory = $true)]
        [string]$StudentAlias
    )

    $raw = "$Prefix$StudentAlias"
    $safe = $raw -replace '[^a-zA-Z0-9_]', ''
    if ($safe.Length -gt 64) {
        $safe = $safe.Substring(0, 64)
    }

    return $safe
}

function Get-SafeSiteAlias {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [Parameter(Mandatory = $true)]
        [string]$StudentAlias
    )

    $raw = "$Prefix-$StudentAlias"
    $safe = $raw -replace '[^a-zA-Z0-9_-]', ''
    $safe = $safe.Trim('-')
    if ($safe.Length -gt 64) {
        $safe = $safe.Substring(0, 64)
    }

    return $safe
}

function Get-SafeDomainName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [Parameter(Mandatory = $true)]
        [string]$StudentAlias
    )

    $safePrefix = ($Prefix -replace '[^a-zA-Z0-9\-]', '').Trim('-').ToLowerInvariant()
    $safeAlias = ($StudentAlias -replace '[^a-zA-Z0-9\-]', '').Trim('-').ToLowerInvariant()
    if ([string]::IsNullOrWhiteSpace($safeAlias)) {
        throw 'Student alias must contain at least one letter or number.'
    }

    $maxLength = 24
    $separator = '-'
    $reservedAliasLength = [Math]::Min([Math]::Max($safeAlias.Length, 4), 8)
    $aliasPart = if ($safeAlias.Length -gt $reservedAliasLength) {
        $safeAlias.Substring(0, $reservedAliasLength)
    }
    else {
        $safeAlias
    }

    $prefixMaxLength = $maxLength - $separator.Length - $aliasPart.Length
    if ($prefixMaxLength -lt 1) {
        if ($aliasPart.Length -gt $maxLength) {
            return $aliasPart.Substring(0, $maxLength)
        }

        return $aliasPart
    }

    $prefixPart = if ($safePrefix.Length -gt $prefixMaxLength) {
        $safePrefix.Substring(0, $prefixMaxLength)
    }
    else {
        $safePrefix
    }

    if ([string]::IsNullOrWhiteSpace($prefixPart)) {
        return $aliasPart
    }

    return "$prefixPart-$aliasPart".Trim('-')
}

function Get-PacEnvironmentListJson {
    $rawOutput = pac admin list --json 2>&1
    $jsonLines = ($rawOutput | ForEach-Object { $_.ToString() }) -join "`n"
    $jsonLines = ($jsonLines -split "`n" | Where-Object { $_ -notmatch '^\s*\[[\d:]+\]' }) -join "`n"

    if ([string]::IsNullOrWhiteSpace($jsonLines)) {
        throw "pac admin list returned no JSON after filtering diagnostic output. Raw output: $((($rawOutput | ForEach-Object { $_.ToString() }) -join '`n'))"
    }

    return $jsonLines | ConvertFrom-Json
}

function Find-PacEnvironmentByDomainName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    $normalizedDomainName = $DomainName.Trim().ToLowerInvariant()
    $envList = @(Get-PacEnvironmentListJson)
    return @(
        $envList | Where-Object {
            $environmentUrl = [string]$_.EnvironmentUrl
            if ([string]::IsNullOrWhiteSpace($environmentUrl)) {
                return $false
            }

            try {
                $uri = [Uri]$environmentUrl
                $hostLabel = ($uri.Host -split '\.')[0].ToLowerInvariant()
                return $hostLabel -eq $normalizedDomainName
            }
            catch {
                return $environmentUrl.ToLowerInvariant().Contains($normalizedDomainName)
            }
        } | Select-Object -First 1
    )
}

function Resolve-EnvironmentGuid {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    $target = Find-PacEnvironmentByDomainName -DomainName $DomainName
    if ($null -eq $target) {
        return $null
    }

    $guid = $target.EnvironmentId
    if ([string]::IsNullOrWhiteSpace($guid)) {
        $guid = $target.environmentId
    }
    if ([string]::IsNullOrWhiteSpace($guid)) {
        $guid = $target.EnvironmentID
    }

    return $guid
}

function Get-PowerPlatformAccessToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret
    )

    return Get-OAuthAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -Scope 'https://api.powerplatform.com/.default'
}

function Get-OAuthAccessToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $true)]
        [string]$Scope
    )

    $tokenResponse = Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -ContentType 'application/x-www-form-urlencoded' `
        -TimeoutSec 30 `
        -Body @{
            grant_type    = 'client_credentials'
            client_id     = $ClientId
            client_secret = $ClientSecret
            scope         = $Scope
        }

    return $tokenResponse.access_token
}

function Get-DataverseAccessToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl
    )

    $normalizedEnvironmentUrl = $EnvironmentUrl.TrimEnd('/')
    return Get-OAuthAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret -Scope "$normalizedEnvironmentUrl/.default"
}

function Ensure-DataverseApplicationUser {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$ApplicationId,

        [Parameter()]
        [string]$Role = 'System Administrator'
    )

    Require-Command -Name 'pac'
    Invoke-NativeCommand -FilePath 'pac' -Arguments @(
        'admin',
        'assign-user',
        '--environment',
        $EnvironmentUrl,
        '--user',
        $ApplicationId,
        '--role',
        $Role,
        '--application-user'
    ) -FailureMessage "Unable to register application '$ApplicationId' as a Dataverse application user in '$EnvironmentUrl'." | Out-Null
}

function Get-WorkshopAppClientContext {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    $tenantId = Get-RequiredString -Value ([string]$Config.TenantId) -Name 'TenantId'
    $clientId = Get-RequiredString -Value ([string]$Config.SharePoint.PnPClientId) -Name 'SharePoint.PnPClientId'
    $secretInfo = Resolve-ConfiguredClientSecret -Config $Config
    if ([string]::IsNullOrWhiteSpace($secretInfo.Value)) {
        throw "A client secret is required for Dataverse automation. Populate Identity.ClientSecret or the environment variable named by Identity.ClientSecretEnvVar."
    }

    return [pscustomobject]@{
        TenantId     = $tenantId
        ClientId     = $clientId
        ClientSecret = $secretInfo.Value
        SecretSource = $secretInfo.Source
    }
}

function New-DataverseWebApiHeaders {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    return @{
        Authorization      = "Bearer $AccessToken"
        Accept             = 'application/json'
        'OData-Version'    = '4.0'
        'OData-MaxVersion' = '4.0'
    }
}

function New-DataverseClientContext {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter()]
        [switch]$EnsureApplicationUserPresent
    )

    $normalizedEnvironmentUrl = $EnvironmentUrl.Trim().TrimEnd('/')
    $appContext = Get-WorkshopAppClientContext -Config $Config

    if ($EnsureApplicationUserPresent) {
        [void](Ensure-DataverseApplicationUser -EnvironmentUrl $normalizedEnvironmentUrl -ApplicationId $appContext.ClientId)
    }

    $accessToken = Get-DataverseAccessToken `
        -TenantId $appContext.TenantId `
        -ClientId $appContext.ClientId `
        -ClientSecret $appContext.ClientSecret `
        -EnvironmentUrl $normalizedEnvironmentUrl

    return [pscustomobject]@{
        EnvironmentUrl = $normalizedEnvironmentUrl
        AccessToken    = $accessToken
        Headers        = (New-DataverseWebApiHeaders -AccessToken $accessToken)
        ClientId       = $appContext.ClientId
    }
}

function Invoke-DataverseWebApiRequest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$RelativeUri,

        [Parameter()]
        [ValidateSet('GET', 'POST', 'PATCH', 'DELETE')]
        [string]$Method = 'GET',

        [Parameter()]
        [AllowNull()]
        [object]$Body
    )

    $normalizedEnvironmentUrl = $EnvironmentUrl.Trim().TrimEnd('/')
    $normalizedRelativeUri = $RelativeUri.Trim()

    $uri = if ($normalizedRelativeUri -match '^https?://') {
        $normalizedRelativeUri
    }
    elseif ($normalizedRelativeUri.StartsWith('api/data/v9.2/', [System.StringComparison]::OrdinalIgnoreCase)) {
        "$normalizedEnvironmentUrl/$normalizedRelativeUri"
    }
    else {
        "$normalizedEnvironmentUrl/api/data/v9.2/$($normalizedRelativeUri.TrimStart('/'))"
    }

    $requestParameters = @{
        Method  = $Method
        Uri     = $uri
        Headers = (New-DataverseWebApiHeaders -AccessToken $AccessToken)
    }

    if ($PSBoundParameters.ContainsKey('Body')) {
        $requestParameters.ContentType = 'application/json'
        $requestParameters.Body = if ($Body -is [string]) {
            $Body
        }
        else {
            $Body | ConvertTo-Json -Depth 20
        }
    }

    return Invoke-RestMethod @requestParameters -TimeoutSec 120
}

function Set-EnvironmentCopilotCredits {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentGuid,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter()]
        [int]$Credits = 25000
    )

    $body = @{
        currencyAllocations = @(
            @{
                currencyType = 'MCSSessions'
                allocated    = $Credits
            }
        )
    } | ConvertTo-Json -Depth 5

    Invoke-RestMethod -Method PATCH `
        -Uri "https://api.powerplatform.com/licensing/environments/$EnvironmentGuid/allocations?api-version=2022-03-01-preview" `
        -ContentType 'application/json' `
        -Headers @{ Authorization = "Bearer $AccessToken" } `
        -TimeoutSec 60 `
        -Body $body
}

function Confirm-EnvironmentCopilotCredits {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentGuid,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter()]
        [int]$ExpectedCredits = 25000
    )

    $response = Invoke-RestMethod -Method GET `
        -Uri "https://api.powerplatform.com/licensing/environments/$EnvironmentGuid/allocations?api-version=2022-03-01-preview" `
        -Headers @{ Authorization = "Bearer $AccessToken" } `
        -TimeoutSec 60

    $allocs = $response.currencyAllocations
    if ($null -eq $allocs) { $allocs = $response.value }
    if ($null -eq $allocs) { $allocs = $response.allocations }

    $mcs = $allocs | Where-Object { $_.currencyType -eq 'MCSSessions' }
    if (-not $mcs -or $mcs.allocated -lt $ExpectedCredits) {
        throw "Copilot Credits verification failed for environment $EnvironmentGuid. Expected $ExpectedCredits, got $($mcs.allocated)."
    }

    return $mcs
}

function Invoke-WithRetry {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [Parameter()]
        [int]$MaxAttempts = 3,

        [Parameter()]
        [int]$DelaySeconds = 30,

        [Parameter()]
        [string]$OperationName = 'operation',

        [Parameter()]
        [string[]]$NonRetryablePatterns = @()
    )

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            return & $ScriptBlock
        }
        catch {
            $reason = [string]$_.CategoryInfo.Reason
            $exceptionTypeName = if ($null -ne $_.Exception) { $_.Exception.GetType().Name } else { '' }
            $nonRetryableTypes = @('AuthenticationException', 'UnauthorizedAccessException', 'SecurityException')
            if ($exceptionTypeName -in $nonRetryableTypes -or $reason -match '(?i)(auth|unauthor)') {
                throw "$OperationName failed without retry because the error is non-retryable (exception: $exceptionTypeName, reason: $reason). Last error: $_"
            }

            $errorText = $_.ToString()
            $matchedNonRetryablePattern = $NonRetryablePatterns | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $errorText -match $_ } | Select-Object -First 1
            if ($matchedNonRetryablePattern) {
                throw "$OperationName failed without retry because the error matched the non-retryable pattern '$matchedNonRetryablePattern'. Last error: $_"
            }

            if ($i -ge $MaxAttempts) {
                throw "$OperationName failed after $MaxAttempts attempts. Last error: $_"
            }

            Write-Log -Level WARN -Message "$OperationName attempt $i/$MaxAttempts failed: $_ — retrying in ${DelaySeconds}s"
            Start-Sleep -Seconds $DelaySeconds
        }
    }
}

function Save-StudentEnvironmentMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [array]$StudentMap
    )

    $json = ConvertTo-Json -InputObject @($StudentMap) -Depth 10
    $tempPath = "$Path.tmp"
    Set-Content -LiteralPath $tempPath -Value $json -Encoding UTF8
    Move-Item -Force -LiteralPath $tempPath -Destination $Path
}

function Read-StudentEnvironmentMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return @()
    }

    $content = Get-Content -LiteralPath $Path -Raw
    if ([string]::IsNullOrWhiteSpace($content)) {
        return @()
    }

    $map = $content | ConvertFrom-Json -Depth 10
    if ($null -eq $map) {
        return @()
    }

    return @($map)
}

function Ensure-SecurityGroup {
    <#
    .SYNOPSIS
        Ensures a Microsoft Entra security group exists and contains the specified members.
    .DESCRIPTION
        Requires an active Connect-MgGraph session with Group.ReadWrite.All permission.
        Creates the group if it does not exist, then adds any missing members.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter()]
        [string]$Description = '',

        [Parameter()]
        [string[]]$MemberEmails = @()
    )

    $existingGroup = Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$DisplayName' and securityEnabled eq true&`$select=id,displayName" `
        -ErrorAction Stop

    $group = $existingGroup.value | Select-Object -First 1

    if ($null -eq $group) {
        Write-Log -Level INFO -Message "Creating security group '$DisplayName'..." -Component 'GROUP'
        $groupBody = @{
            displayName     = $DisplayName
            description     = $Description
            mailEnabled     = $false
            mailNickname    = ($DisplayName -replace '[^a-zA-Z0-9]', '')
            securityEnabled = $true
        } | ConvertTo-Json -Depth 5

        $group = Invoke-MgGraphRequest -Method POST `
            -Uri 'https://graph.microsoft.com/v1.0/groups' `
            -Body $groupBody `
            -ContentType 'application/json'
        Write-Log -Level PASS -Message "Security group '$DisplayName' created (id=$($group.id))." -Component 'GROUP'
    } else {
        Write-Log -Level PASS -Message "Security group '$DisplayName' already exists (id=$($group.id))." -Component 'GROUP'
    }

    if ($MemberEmails.Count -eq 0) {
        return $group
    }

    # Get current members
    $currentMembers = Invoke-MgGraphRequest -Method GET `
        -Uri "https://graph.microsoft.com/v1.0/groups/$($group.id)/members?`$select=id,userPrincipalName" `
        -ErrorAction SilentlyContinue
    $currentUpns = @()
    if ($currentMembers.value) {
        $currentUpns = @($currentMembers.value | ForEach-Object { $_.userPrincipalName })
    }

    foreach ($email in $MemberEmails) {
        if ($email -in $currentUpns) {
            Write-Log -Level PASS -Message "$email is already a member of '$DisplayName'." -Component 'GROUP'
            continue
        }
        try {
            $user = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users/$email" -ErrorAction Stop
            $memberBody = @{
                '@odata.id' = "https://graph.microsoft.com/v1.0/directoryObjects/$($user.id)"
            } | ConvertTo-Json

            Invoke-MgGraphRequest -Method POST `
                -Uri "https://graph.microsoft.com/v1.0/groups/$($group.id)/members/`$ref" `
                -Body $memberBody `
                -ContentType 'application/json'
            Write-Log -Level PASS -Message "Added $email to '$DisplayName'." -Component 'GROUP'
        }
        catch {
            Write-Log -Level WARN -Message "Failed to add $email to '$DisplayName': $_" -Component 'GROUP'
        }
    }

    return $group
}
