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

    return $Value -match '^<.+>$'
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

    if ($Value -match '^<.+>$') {
        throw "Config value '$Name' still contains a placeholder value: $Value"
    }

    return $Value
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

    $raw = "$Prefix-$StudentAlias"
    $safe = $raw -replace '[^a-zA-Z0-9\-]', ''
    $safe = $safe.Trim('-')
    $safe = $safe.ToLowerInvariant()
    if ($safe.Length -gt 24) {
        $safe = $safe.Substring(0, 24)
    }
    $safe = $safe.TrimEnd('-')
    return $safe
}

function Get-PacEnvironmentListJson {
    $rawOutput = pac admin list --json 2>&1
    $jsonLines = ($rawOutput | ForEach-Object { $_.ToString() }) -join "`n"
    $jsonLines = ($jsonLines -split "`n" | Where-Object { $_ -notmatch '^\s*\[[\d:]+\]' }) -join "`n"

    if ([string]::IsNullOrWhiteSpace($jsonLines)) {
        throw 'pac admin list --json returned no usable output.'
    }

    return $jsonLines | ConvertFrom-Json
}

function Resolve-EnvironmentGuid {
    param(
        [Parameter(Mandatory = $true)]
        [string]$DomainName
    )

    $envList = Get-PacEnvironmentListJson
    $target = $envList | Where-Object { $_.EnvironmentUrl -like "*$DomainName*" } | Select-Object -First 1
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

    $tokenResponse = Invoke-RestMethod -Method POST `
        -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
        -ContentType 'application/x-www-form-urlencoded' `
        -Body @{
            grant_type    = 'client_credentials'
            client_id     = $ClientId
            client_secret = $ClientSecret
            scope         = 'https://api.powerplatform.com/.default'
        }

    return $tokenResponse.access_token
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
        -Headers @{ Authorization = "Bearer $AccessToken" }

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
        [string]$OperationName = 'operation'
    )

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            return & $ScriptBlock
        }
        catch {
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
        [array]$StudentMap
    )

    $StudentMap | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Read-StudentEnvironmentMap {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return @()
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 10
}
