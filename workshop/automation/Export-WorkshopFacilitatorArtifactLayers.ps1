[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$ManifestPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-manifest.json'),

    [Parameter()]
    [string]$EnvironmentUrl,

    [Parameter()]
    [string]$OutputPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-artifacts.json')
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Get-FacilitatorFallbackManifest {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Fallback manifest '$Path' was not found."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100
}

function Get-ConfiguredFallbackSourceEnvironmentUrl {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config
    )

    if ($Config.PSObject.Properties.Match('FacilitatorFallback').Count -eq 0 -or $null -eq $Config.FacilitatorFallback) {
        return $null
    }

    $candidate = Get-OptionalConfigString -Value $Config.FacilitatorFallback.SourceEnvironmentUrl
    if ([string]::IsNullOrWhiteSpace($candidate) -or (Test-PlaceholderValue -Value $candidate)) {
        return $null
    }

    return $candidate.Trim().TrimEnd('/')
}

function Get-DataverseRows {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context,

        [Parameter(Mandatory = $true)]
        [string]$RelativeUri
    )

    $response = Invoke-DataverseWebApiRequest -EnvironmentUrl $Context.EnvironmentUrl -AccessToken $Context.AccessToken -RelativeUri $RelativeUri
    if ($null -eq $response -or $null -eq $response.value) {
        return @()
    }

    return @($response.value)
}

function Get-ConnectionReferenceSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    $rows = Get-DataverseRows -Context $Context -RelativeUri "connectionreferences?`$select=connectionreferenceid,connectionreferencedisplayname,connectionreferencelogicalname,connectorid,connectionid,statecode,statuscode&`$orderby=connectionreferencelogicalname"
    return @(
        $rows |
            Sort-Object { [string]$_.connectionreferencelogicalname } |
            ForEach-Object {
                [pscustomobject]@{
                    connectionReferenceId = [string]$_.connectionreferenceid
                    displayName           = [string]$_.connectionreferencedisplayname
                    logicalName           = [string]$_.connectionreferencelogicalname
                    connectorId           = [string]$_.connectorid
                    connectionId          = [string]$_.connectionid
                    stateCode             = [int]$_.statecode
                    statusCode            = [int]$_.statuscode
                    hasConnectionId       = -not [string]::IsNullOrWhiteSpace([string]$_.connectionid)
                }
            }
    )
}

function Get-EnvironmentVariableValueSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Context
    )

    $rows = Get-DataverseRows -Context $Context -RelativeUri "environmentvariablevalues?`$select=environmentvariablevalueid,value&`$expand=EnvironmentVariableDefinitionId(`$select=environmentvariabledefinitionid,displayname,schemaname,defaultvalue,type)&`$orderby=EnvironmentVariableDefinitionId/schemaname"
    return @(
        $rows |
            Sort-Object { [string]$_.EnvironmentVariableDefinitionId.schemaname } |
            ForEach-Object {
                [pscustomobject]@{
                    environmentVariableValueId      = [string]$_.environmentvariablevalueid
                    environmentVariableDefinitionId = [string]$_.EnvironmentVariableDefinitionId.environmentvariabledefinitionid
                    displayName                     = [string]$_.EnvironmentVariableDefinitionId.displayname
                    schemaName                      = [string]$_.EnvironmentVariableDefinitionId.schemaname
                    defaultValue                    = [string]$_.EnvironmentVariableDefinitionId.defaultvalue
                    currentValue                    = [string]$_.value
                    type                            = [int]$_.EnvironmentVariableDefinitionId.type
                }
            }
    )
}

function Get-RepairableLabSnapshot {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Manifest
    )

    return @(
        @($Manifest.labs) |
            Where-Object { [string]$_.portability -in @('repairable', 'environment-bound') } |
            Sort-Object { [int]$_.labNumber } |
            ForEach-Object {
                [pscustomobject]@{
                    labNumber         = [int]$_.labNumber
                    title             = [string]$_.title
                    day               = [int]$_.day
                    portability       = [string]$_.portability
                    artifactType      = [string]$_.artifactType
                    buildPath         = [string]$_.buildPath
                    validationSummary = [string]$_.validationSummary
                    manualChecks      = @($_.manualChecks | ForEach-Object { [string]$_ })
                }
            }
    )
}

Write-Section "Loading facilitator artifact packaging inputs"
$config = Get-WorkshopConfig -Path $ConfigPath
$manifest = Get-FacilitatorFallbackManifest -Path $ManifestPath

$sourceEnvironmentUrl = if ($PSBoundParameters.ContainsKey('EnvironmentUrl')) {
    Get-RequiredString -Value $EnvironmentUrl -Name 'EnvironmentUrl'
}
else {
    $configuredSource = Get-ConfiguredFallbackSourceEnvironmentUrl -Config $config
    if ($null -eq $configuredSource) {
        throw "FacilitatorFallback.SourceEnvironmentUrl is not configured. Pass -EnvironmentUrl or qualify a gold source first."
    }

    $configuredSource
}

$configuredTargetEnvironmentUrl = Get-OptionalConfigString -Value $config.EnvironmentUrl
$context = New-DataverseClientContext -Config $config -EnvironmentUrl $sourceEnvironmentUrl -EnsureApplicationUserPresent

Write-StepResult -Level INFO -Message "Packaging facilitator artifact layers from '$sourceEnvironmentUrl'."
if (-not [string]::IsNullOrWhiteSpace($configuredTargetEnvironmentUrl) -and -not (Test-PlaceholderValue -Value $configuredTargetEnvironmentUrl)) {
    Write-StepResult -Level INFO -Message "Configured fallback target environment: $($configuredTargetEnvironmentUrl.TrimEnd('/'))."
}

Write-Section "Collecting repairable facilitator artifacts"
$connectionReferences = @(Get-ConnectionReferenceSnapshot -Context $context)
$environmentVariableValues = @(Get-EnvironmentVariableValueSnapshot -Context $context)
$repairableLabs = @(Get-RepairableLabSnapshot -Manifest $manifest)

$artifactPackage = [ordered]@{
    schemaVersion                  = 1
    capturedOnUtc                  = [DateTime]::UtcNow.ToString('o')
    sourceEnvironmentUrl           = $context.EnvironmentUrl
    configuredTargetEnvironmentUrl = if ([string]::IsNullOrWhiteSpace($configuredTargetEnvironmentUrl) -or (Test-PlaceholderValue -Value $configuredTargetEnvironmentUrl)) { $null } else { $configuredTargetEnvironmentUrl.TrimEnd('/') }
    bindings                       = [ordered]@{
        sourceEnvironmentUrl = $context.EnvironmentUrl
        targetEnvironmentUrl = if ([string]::IsNullOrWhiteSpace($configuredTargetEnvironmentUrl) -or (Test-PlaceholderValue -Value $configuredTargetEnvironmentUrl)) { $null } else { $configuredTargetEnvironmentUrl.TrimEnd('/') }
        sharePointAdminUrl   = Get-OptionalConfigString -Value $config.SharePoint.AdminUrl
        sharePointSiteUrl    = Get-OptionalConfigString -Value $config.SharePoint.SiteUrl
        workshopTeamName     = Get-OptionalConfigString -Value $config.Teams.WorkshopTeamName
        studentTeamPrefix    = Get-OptionalConfigString -Value $config.Teams.StudentTeamPrefix
    }
    buildStrategy                  = [string]$manifest.buildModel.strategy
    connectionReferences           = $connectionReferences
    environmentVariableValues      = $environmentVariableValues
    repairableLabs                 = $repairableLabs
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
if (-not [string]::IsNullOrWhiteSpace($outputDirectory) -and -not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
}

if ($PSCmdlet.ShouldProcess($OutputPath, "Write facilitator artifact snapshot from $sourceEnvironmentUrl")) {
    $artifactPackage | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Write-StepResult -Level PASS -Message "Saved facilitator artifact snapshot to '$OutputPath'."
}
else {
    Write-StepResult -Level INFO -Message "Skipped writing '$OutputPath' because -WhatIf was supplied."
}

Write-StepResult -Level PASS -Message "Captured $($connectionReferences.Count) connection reference snapshot(s)."
Write-StepResult -Level PASS -Message "Captured $($environmentVariableValues.Count) environment variable value snapshot(s)."
Write-StepResult -Level PASS -Message "Captured $($repairableLabs.Count) repairable or environment-bound lab checklist item(s)."
