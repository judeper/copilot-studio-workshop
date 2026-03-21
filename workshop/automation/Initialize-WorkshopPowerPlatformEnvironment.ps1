[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$CreateEnvironment,

    [Parameter()]
    [switch]$UpdateConfig
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

$allowedEnvironmentTypes = @('Trial', 'Sandbox', 'Production', 'Developer', 'Teams', 'SubscriptionBasedTrial')

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

function Invoke-PacCommandWithOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage
    )

    $output = & 'pac' @Arguments 2>&1
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

function Get-PacEnvironmentUrls {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @()
    }

    $urlMatches = [regex]::Matches($Text, 'https://[A-Za-z0-9.-]+(?:/[^\s|]*)?', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    return @($urlMatches | ForEach-Object { $_.Value.TrimEnd('/') } | Sort-Object -Unique)
}

function Get-EnvironmentHostPrefix {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl
    )

    $uri = [uri]$EnvironmentUrl
    return ($uri.Host -split '\.')[0].ToLowerInvariant()
}

function Resolve-ExistingEnvironmentUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$KnownEnvironmentUrls,

        [Parameter(Mandatory = $true)]
        [string]$DomainName,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ConfiguredEnvironmentUrl
    )

    $normalizedDomainName = $DomainName.ToLowerInvariant()
    $candidateUrls = @(
        $KnownEnvironmentUrls |
            Where-Object {
                $hostPrefix = Get-EnvironmentHostPrefix -EnvironmentUrl $_
                $hostPrefix -match ('^{0}\d*$' -f [regex]::Escape($normalizedDomainName))
            } |
            Sort-Object -Unique
    )

    if (-not [string]::IsNullOrWhiteSpace($ConfiguredEnvironmentUrl)) {
        $normalizedConfiguredEnvironmentUrl = $ConfiguredEnvironmentUrl.TrimEnd('/')
        if ($normalizedConfiguredEnvironmentUrl -in $candidateUrls) {
            return $normalizedConfiguredEnvironmentUrl
        }
    }

    if ($candidateUrls.Count -eq 1) {
        return $candidateUrls[0]
    }

    if ($candidateUrls.Count -gt 1) {
        throw "Multiple environments already use the configured domain prefix '$DomainName': $($candidateUrls -join ', '). Review the tenant state and update workshop-config.json before continuing."
    }

    return $null
}

function Get-EnvironmentDiscoveryResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$ConfiguredEnvironmentUrl,

        [Parameter()]
        [ValidateRange(1, 30)]
        [int]$Attempts = 1,

        [Parameter()]
        [ValidateRange(0, 60)]
        [int]$DelaySeconds = 0
    )

    $knownEnvironmentUrls = @()
    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        $environmentListOutput = Invoke-PacCommandWithOutput -Arguments @('admin', 'list') -FailureMessage 'Unable to enumerate Power Platform environments with pac admin list. Confirm the active pac profile is signed in to the intended tenant and has environment admin permissions.'
        $knownEnvironmentUrls = @(Get-PacEnvironmentUrls -Text $environmentListOutput)
        $resolvedEnvironmentUrl = Resolve-ExistingEnvironmentUrl -KnownEnvironmentUrls $knownEnvironmentUrls -DomainName $DomainName -ConfiguredEnvironmentUrl $ConfiguredEnvironmentUrl

        if ($null -ne $resolvedEnvironmentUrl) {
            return [pscustomobject]@{
                KnownEnvironmentUrls  = $knownEnvironmentUrls
                ResolvedEnvironmentUrl = $resolvedEnvironmentUrl
            }
        }

        if ($attempt -lt $Attempts -and $DelaySeconds -gt 0) {
            Start-Sleep -Seconds $DelaySeconds
        }
    }

    return [pscustomobject]@{
        KnownEnvironmentUrls  = $knownEnvironmentUrls
        ResolvedEnvironmentUrl = $null
    }
}

function Set-ConfiguredEnvironmentUrl {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$ResolvedEnvironmentUrl
    )

    $normalizedResolvedEnvironmentUrl = $ResolvedEnvironmentUrl.TrimEnd('/')
    $currentEnvironmentUrl = Get-OptionalConfigString -Value $Config.EnvironmentUrl

    if (-not (Test-PlaceholderValue -Value $currentEnvironmentUrl) -and $currentEnvironmentUrl.TrimEnd('/') -ne $normalizedResolvedEnvironmentUrl) {
        throw "Config value 'EnvironmentUrl' already contains '$currentEnvironmentUrl'. Refusing to overwrite it with '$normalizedResolvedEnvironmentUrl'."
    }

    if ($Config.PSObject.Properties.Match('EnvironmentUrl').Count -eq 0) {
        $Config | Add-Member -NotePropertyName 'EnvironmentUrl' -NotePropertyValue $normalizedResolvedEnvironmentUrl
    }
    else {
        $Config.EnvironmentUrl = $normalizedResolvedEnvironmentUrl
    }
}

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'
$configuredEnvironmentUrl = Get-OptionalConfigString -Value $config.EnvironmentUrl

$bootstrapConfig = $config.EnvironmentBootstrap
if ($null -eq $bootstrapConfig) {
    throw "Config section 'EnvironmentBootstrap' is required for environment bootstrap. Copy the section from workshop-config.example.json and populate the environment values first."
}

$environmentDisplayName = Get-RequiredString -Value (Get-OptionalConfigString -Value $bootstrapConfig.DisplayName) -Name 'EnvironmentBootstrap.DisplayName'
$environmentType = Get-RequiredString -Value (Get-OptionalConfigString -Value $bootstrapConfig.Type) -Name 'EnvironmentBootstrap.Type'
$domainName = Get-RequiredString -Value (Get-OptionalConfigString -Value $bootstrapConfig.DomainName) -Name 'EnvironmentBootstrap.DomainName'
$region = Get-OptionalConfigString -Value $bootstrapConfig.Region
$currency = Get-OptionalConfigString -Value $bootstrapConfig.Currency
$language = Get-OptionalConfigString -Value $bootstrapConfig.Language
$adminUser = Get-OptionalConfigString -Value $bootstrapConfig.AdminUser
$securityGroupId = Get-OptionalConfigString -Value $bootstrapConfig.SecurityGroupId

if ($environmentType -notin $allowedEnvironmentTypes) {
    throw "EnvironmentBootstrap.Type '$environmentType' is not supported by the helper. Supported values: $($allowedEnvironmentTypes -join ', ')."
}

if ($domainName -notmatch '^(?!-)(?!.*--)[A-Za-z0-9-]+(?<!-)$') {
    throw "EnvironmentBootstrap.DomainName '$domainName' is not valid for pac admin create. Use only letters, numbers, or single hyphens, and do not start or end with a hyphen."
}

if ([string]::IsNullOrWhiteSpace($region)) {
    $region = 'unitedstates'
}

if ([string]::IsNullOrWhiteSpace($currency)) {
    $currency = 'USD'
}

if ([string]::IsNullOrWhiteSpace($language)) {
    $language = 'English'
}

if ($environmentType -eq 'Teams' -and [string]::IsNullOrWhiteSpace($securityGroupId)) {
    throw "EnvironmentBootstrap.SecurityGroupId is required when EnvironmentBootstrap.Type is 'Teams'."
}

if (-not [string]::IsNullOrWhiteSpace($securityGroupId)) {
    $parsedSecurityGroupId = [guid]::Empty
    if (-not [guid]::TryParse($securityGroupId, [ref]$parsedSecurityGroupId)) {
        throw "EnvironmentBootstrap.SecurityGroupId '$securityGroupId' is not a valid GUID."
    }
}

$normalizedDomainName = $domainName.ToLowerInvariant()
if (-not (Test-PlaceholderValue -Value $configuredEnvironmentUrl)) {
    $configuredHostPrefix = Get-EnvironmentHostPrefix -EnvironmentUrl $configuredEnvironmentUrl
    if ($configuredHostPrefix -notmatch ('^{0}\d*$' -f [regex]::Escape($normalizedDomainName))) {
        throw "Configured EnvironmentUrl '$($configuredEnvironmentUrl.TrimEnd('/'))' does not match EnvironmentBootstrap.DomainName '$domainName'. Clear EnvironmentUrl back to a placeholder or align the bootstrap settings before using this helper."
    }
}

Write-StepResult -Level PASS -Message "Loaded environment bootstrap settings for '$environmentDisplayName' ($environmentType) in region '$region'."
if (Test-PlaceholderValue -Value $configuredEnvironmentUrl) {
    Write-StepResult -Level INFO -Message "EnvironmentUrl is still blank or placeholder and can be captured after the environment is discovered or created."
}
else {
    Write-StepResult -Level INFO -Message "Current config EnvironmentUrl: $($configuredEnvironmentUrl.TrimEnd('/'))"
}

Write-Section "Checking Power Platform automation support"
Require-Command -Name 'pac'
Write-StepResult -Level PASS -Message "Power Platform CLI (pac) is available."
Invoke-PacCommandWithOutput -Arguments @('auth', 'list') -FailureMessage 'Unable to inspect Power Platform CLI auth profiles. Run pac auth create with a Power Platform admin-capable account before using this helper.' | Out-Null
Write-StepResult -Level PASS -Message "pac auth profiles are available. Ensure the active profile targets tenant '$tenantId' and has the rights needed to create environments."

Write-Section "Checking for an existing workshop environment"
$environmentDiscovery = Get-EnvironmentDiscoveryResult -DomainName $domainName -ConfiguredEnvironmentUrl $configuredEnvironmentUrl -Attempts 1 -DelaySeconds 0
$knownEnvironmentUrls = @($environmentDiscovery.KnownEnvironmentUrls)
$resolvedEnvironmentUrl = $environmentDiscovery.ResolvedEnvironmentUrl

if ($knownEnvironmentUrls.Count -gt 0) {
    Write-StepResult -Level PASS -Message "Enumerated $($knownEnvironmentUrls.Count) environment URL(s) from the active tenant context."
}
else {
    Write-StepResult -Level WARN -Message "pac admin list returned no environment URLs. The tenant may be empty, or the active pac profile may not expose admin-visible environments."
}

if (-not (Test-PlaceholderValue -Value $configuredEnvironmentUrl) -and $configuredEnvironmentUrl.TrimEnd('/') -notin $knownEnvironmentUrls) {
    Write-StepResult -Level WARN -Message "Configured EnvironmentUrl '$($configuredEnvironmentUrl.TrimEnd('/'))' was not returned by pac admin list. Confirm the active pac profile points at the correct tenant."
}

if ($null -ne $resolvedEnvironmentUrl) {
    Write-StepResult -Level PASS -Message "Found an existing environment that matches the configured domain prefix: $resolvedEnvironmentUrl"

    if ($UpdateConfig) {
        Set-ConfiguredEnvironmentUrl -Config $config -ResolvedEnvironmentUrl $resolvedEnvironmentUrl
        Save-WorkshopConfig -Path $ConfigPath -Config $config
        Write-StepResult -Level PASS -Message "Updated '$ConfigPath' with EnvironmentUrl '$resolvedEnvironmentUrl'."
    }

    if ($CreateEnvironment) {
        Write-StepResult -Level INFO -Message "Skipping pac admin create because the intended environment already exists. This keeps the facilitator pre-stage idempotent."
    }

    Write-StepResult -Level INFO -Message "This helper only covers facilitator-owned environment bootstrap. Student Lab 00 environment selection and later maker work remain part of the workshop walkthrough."
    return
}

$createArguments = @(
    'admin', 'create',
    '--name', $environmentDisplayName,
    '--type', $environmentType,
    '--domain', $domainName,
    '--region', $region,
    '--currency', $currency,
    '--language', $language,
    # D365_CDSSampleApp triggers Dataverse provisioning as a side effect.
    # Without a template, Sandbox environments are created without Dataverse,
    # which blocks Copilot Studio. This template is enabled for unitedstates
    # but may be disabled in other regions — verify with pac admin list-app-templates.
    '--templates', 'D365_CDSSampleApp'
)

if (-not [string]::IsNullOrWhiteSpace($adminUser) -and -not (Test-PlaceholderValue -Value $adminUser)) {
    $createArguments += @('--user', $adminUser)
}

if (-not [string]::IsNullOrWhiteSpace($securityGroupId) -and -not (Test-PlaceholderValue -Value $securityGroupId)) {
    $createArguments += @('--security-group-id', $securityGroupId)
}

$displayArguments = @($createArguments | ForEach-Object {
        if ($_ -match '\s') {
            '"{0}"' -f $_
        }
        else {
            $_
        }
    })

Write-StepResult -Level INFO -Message "Supported bootstrap command: pac $($displayArguments -join ' ')"
Write-StepResult -Level WARN -Message "Environment creation still depends on tenant capacity, licensing, and admin permissions. This helper does not assign Copilot Studio author groups, maker roles, or DLP policies."

if (-not $CreateEnvironment) {
    Write-StepResult -Level WARN -Message "No existing environment matched domain prefix '$domainName'. Re-run this script with -CreateEnvironment after confirming the active pac profile is the correct facilitator admin context."
    return
}

Write-Section "Creating the workshop environment"
Write-StepResult -Level INFO -Message "Using the officially supported pac admin create flow to provision a facilitator-owned workshop environment."

if (-not $PSCmdlet.ShouldProcess($environmentDisplayName, 'Create Power Platform environment')) {
    return
}

Invoke-PacCommandWithOutput -Arguments $createArguments -FailureMessage 'Power Platform environment creation failed. Review the pac output for capacity, licensing, or permission issues.' | Out-Null
Write-StepResult -Level PASS -Message "pac admin create completed. Resolving the new environment URL from the tenant environment list."

$createdEnvironmentDiscovery = Get-EnvironmentDiscoveryResult -DomainName $domainName -ConfiguredEnvironmentUrl $configuredEnvironmentUrl -Attempts 6 -DelaySeconds 10
$resolvedCreatedEnvironmentUrl = $createdEnvironmentDiscovery.ResolvedEnvironmentUrl

if ($null -eq $resolvedCreatedEnvironmentUrl) {
    throw "The environment creation command finished, but the helper could not resolve the new environment URL from pac admin list. Run 'pac admin list' manually, capture the created environment URL, and update '$ConfigPath' before running the rest of the workshop provisioning scripts."
}

Write-StepResult -Level PASS -Message "Resolved environment URL: $resolvedCreatedEnvironmentUrl"

if ($UpdateConfig) {
    Set-ConfiguredEnvironmentUrl -Config $config -ResolvedEnvironmentUrl $resolvedCreatedEnvironmentUrl
    Save-WorkshopConfig -Path $ConfigPath -Config $config
    Write-StepResult -Level PASS -Message "Updated '$ConfigPath' with EnvironmentUrl '$resolvedCreatedEnvironmentUrl'."
}
else {
    Write-StepResult -Level WARN -Message "The config file was not updated automatically. Add '$resolvedCreatedEnvironmentUrl' to EnvironmentUrl in '$ConfigPath' before running the rest of the toolkit."
}

Write-StepResult -Level INFO -Message "Environment bootstrap is a facilitator pre-stage step only. Student-owned labs still require their own walkthrough steps, permissions, and validation."
