Set-StrictMode -Version Latest

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
