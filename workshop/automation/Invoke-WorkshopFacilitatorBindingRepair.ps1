[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [string]$ArtifactPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-artifacts.json'),

    [Parameter()]
    [string]$ReportPath = (Join-Path -Path $PSScriptRoot -ChildPath 'facilitator-fallback-repair-report.json'),

    [Parameter()]
    [string]$EnvironmentUrl,

    [Parameter()]
    [switch]$ValidateOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Get-ArtifactPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Facilitator artifact snapshot '$Path' was not found. Run Export-WorkshopFacilitatorArtifactLayers.ps1 first."
    }

    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -Depth 100
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

function Get-ReplacementRules {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$ArtifactPackage,

        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$TargetEnvironmentUrl
    )

    $rules = [System.Collections.Generic.List[object]]::new()

    $sourceEnvironmentUrl = [string]$ArtifactPackage.bindings.sourceEnvironmentUrl
    if (-not [string]::IsNullOrWhiteSpace($sourceEnvironmentUrl) -and $sourceEnvironmentUrl.TrimEnd('/') -ne $TargetEnvironmentUrl.TrimEnd('/')) {
        [void]$rules.Add([pscustomobject]@{
            Name   = 'EnvironmentUrl'
            Source = $sourceEnvironmentUrl.TrimEnd('/')
            Target = $TargetEnvironmentUrl.TrimEnd('/')
        })
    }

    $sourceSharePointSiteUrl = [string]$ArtifactPackage.bindings.sharePointSiteUrl
    $targetSharePointSiteUrl = Get-OptionalConfigString -Value $Config.SharePoint.SiteUrl
    if (-not [string]::IsNullOrWhiteSpace($sourceSharePointSiteUrl) -and -not [string]::IsNullOrWhiteSpace($targetSharePointSiteUrl) -and $sourceSharePointSiteUrl.TrimEnd('/') -ne $targetSharePointSiteUrl.TrimEnd('/')) {
        [void]$rules.Add([pscustomobject]@{
            Name   = 'SharePoint.SiteUrl'
            Source = $sourceSharePointSiteUrl.TrimEnd('/')
            Target = $targetSharePointSiteUrl.TrimEnd('/')
        })
    }

    $sourceSharePointAdminUrl = [string]$ArtifactPackage.bindings.sharePointAdminUrl
    $targetSharePointAdminUrl = Get-OptionalConfigString -Value $Config.SharePoint.AdminUrl
    if (-not [string]::IsNullOrWhiteSpace($sourceSharePointAdminUrl) -and -not [string]::IsNullOrWhiteSpace($targetSharePointAdminUrl) -and $sourceSharePointAdminUrl.TrimEnd('/') -ne $targetSharePointAdminUrl.TrimEnd('/')) {
        [void]$rules.Add([pscustomobject]@{
            Name   = 'SharePoint.AdminUrl'
            Source = $sourceSharePointAdminUrl.TrimEnd('/')
            Target = $targetSharePointAdminUrl.TrimEnd('/')
        })
    }

    return @($rules)
}

function Resolve-ExpectedBindingValue {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter()]
        [object[]]$ReplacementRules
    )

    $updatedValue = $Value
    $appliedRules = [System.Collections.Generic.List[string]]::new()

    foreach ($rule in $ReplacementRules) {
        if ([string]::IsNullOrWhiteSpace($updatedValue) -or [string]::IsNullOrWhiteSpace([string]$rule.Source)) {
            continue
        }

        if ($updatedValue.Contains([string]$rule.Source)) {
            $updatedValue = $updatedValue.Replace([string]$rule.Source, [string]$rule.Target)
            [void]$appliedRules.Add([string]$rule.Name)
        }
    }

    return [pscustomobject]@{
        Value        = $updatedValue
        AppliedRules = @($appliedRules)
    }
}

function Write-RepairChecklist {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$RepairableLabs
    )

    if ($RepairableLabs.Count -lt 1) {
        return
    }

    Write-Section "Repair-focused facilitator follow-up"
    foreach ($lab in $RepairableLabs) {
        Write-StepResult -Level INFO -Message ("Lab {0:D2} - {1}: {2}" -f [int]$lab.labNumber, [string]$lab.title, [string]$lab.validationSummary)
        foreach ($manualCheck in @($lab.manualChecks | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })) {
            Write-Host "  - $manualCheck" -ForegroundColor DarkCyan
        }
    }
}

Write-Section "Loading facilitator binding repair inputs"
$config = Get-WorkshopConfig -Path $ConfigPath
$artifactPackage = Get-ArtifactPackage -Path $ArtifactPath

$targetEnvironmentUrl = if ($PSBoundParameters.ContainsKey('EnvironmentUrl')) {
    Get-RequiredString -Value $EnvironmentUrl -Name 'EnvironmentUrl'
}
else {
    Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'
}

$context = New-DataverseClientContext -Config $config -EnvironmentUrl $targetEnvironmentUrl -EnsureApplicationUserPresent
$replacementRules = @(Get-ReplacementRules -ArtifactPackage $artifactPackage -Config $config -TargetEnvironmentUrl $context.EnvironmentUrl)

Write-StepResult -Level INFO -Message "Artifact snapshot: $ArtifactPath"
Write-StepResult -Level INFO -Message "Source artifact environment: $([string]$artifactPackage.sourceEnvironmentUrl)"
Write-StepResult -Level INFO -Message "Target environment under repair: $($context.EnvironmentUrl)"

Write-Section "Comparing connection references"
$sourceConnectionReferences = if ($null -eq $artifactPackage.connectionReferences) { @() } else { @($artifactPackage.connectionReferences) }
$targetConnectionReferences = @(Get-ConnectionReferenceSnapshot -Context $context)
$targetConnectionReferenceMap = @{}
foreach ($targetConnectionReference in $targetConnectionReferences) {
    $targetConnectionReferenceMap[[string]$targetConnectionReference.logicalName] = $targetConnectionReference
}

$connectionReferenceResults = [System.Collections.Generic.List[object]]::new()
$blockingIssues = [System.Collections.Generic.List[string]]::new()

foreach ($sourceConnectionReference in $sourceConnectionReferences) {
    $logicalName = [string]$sourceConnectionReference.logicalName
    $displayName = [string]$sourceConnectionReference.displayName

    if (-not $targetConnectionReferenceMap.ContainsKey($logicalName)) {
        $message = "Missing connection reference '$displayName' ($logicalName) in the target environment."
        Write-StepResult -Level WARN -Message $message
        [void]$blockingIssues.Add($message)
        [void]$connectionReferenceResults.Add([pscustomobject]@{
            logicalName = $logicalName
            displayName = $displayName
            status      = 'missing'
            message     = $message
        })
        continue
    }

    $targetConnectionReference = $targetConnectionReferenceMap[$logicalName]
    if ([string]$sourceConnectionReference.connectorId -ne [string]$targetConnectionReference.connectorId) {
        $message = "Connection reference '$displayName' ($logicalName) points at a different connector in the target environment."
        Write-StepResult -Level WARN -Message $message
        [void]$blockingIssues.Add($message)
        [void]$connectionReferenceResults.Add([pscustomobject]@{
            logicalName = $logicalName
            displayName = $displayName
            status      = 'connector-mismatch'
            message     = $message
        })
        continue
    }

    if ([int]$targetConnectionReference.stateCode -ne 0) {
        $message = "Connection reference '$displayName' ($logicalName) is not active in the target environment."
        Write-StepResult -Level WARN -Message $message
        [void]$blockingIssues.Add($message)
        [void]$connectionReferenceResults.Add([pscustomobject]@{
            logicalName = $logicalName
            displayName = $displayName
            status      = 'inactive'
            message     = $message
        })
        continue
    }

    $message = "Connection reference '$displayName' ($logicalName) is present with the expected connector."
    Write-StepResult -Level PASS -Message $message
    [void]$connectionReferenceResults.Add([pscustomobject]@{
        logicalName = $logicalName
        displayName = $displayName
        status      = 'aligned'
        message     = $message
    })
}

Write-Section "Reconciling environment variable values"
$sourceEnvironmentVariableValues = if ($null -eq $artifactPackage.environmentVariableValues) { @() } else { @($artifactPackage.environmentVariableValues) }
$targetEnvironmentVariableValues = @(Get-EnvironmentVariableValueSnapshot -Context $context)
$targetEnvironmentVariableMap = @{}
foreach ($targetEnvironmentVariableValue in $targetEnvironmentVariableValues) {
    $targetEnvironmentVariableMap[[string]$targetEnvironmentVariableValue.schemaName] = $targetEnvironmentVariableValue
}

$environmentVariableResults = [System.Collections.Generic.List[object]]::new()

foreach ($sourceEnvironmentVariableValue in $sourceEnvironmentVariableValues) {
    $schemaName = [string]$sourceEnvironmentVariableValue.schemaName
    $displayName = [string]$sourceEnvironmentVariableValue.displayName

    if (-not $targetEnvironmentVariableMap.ContainsKey($schemaName)) {
        $message = "Environment variable '$displayName' ($schemaName) is missing from the target environment."
        Write-StepResult -Level WARN -Message $message
        [void]$blockingIssues.Add($message)
        [void]$environmentVariableResults.Add([pscustomobject]@{
            schemaName = $schemaName
            displayName = $displayName
            status = 'missing'
            message = $message
        })
        continue
    }

    $targetEnvironmentVariableValue = $targetEnvironmentVariableMap[$schemaName]
    $resolution = Resolve-ExpectedBindingValue -Value ([string]$sourceEnvironmentVariableValue.currentValue) -ReplacementRules $replacementRules
    $expectedValue = [string]$resolution.Value
    $currentTargetValue = [string]$targetEnvironmentVariableValue.currentValue

    if ($currentTargetValue -eq $expectedValue) {
        $message = "Environment variable '$displayName' ($schemaName) is already aligned."
        Write-StepResult -Level PASS -Message $message
        [void]$environmentVariableResults.Add([pscustomobject]@{
            schemaName = $schemaName
            displayName = $displayName
            status = 'aligned'
            message = $message
        })
        continue
    }

    if ($resolution.AppliedRules.Count -gt 0 -and $currentTargetValue -eq [string]$sourceEnvironmentVariableValue.currentValue) {
        if ($ValidateOnly) {
            $message = "Environment variable '$displayName' ($schemaName) still contains source-environment values and would be updated by rules: $($resolution.AppliedRules -join ', ')."
            Write-StepResult -Level WARN -Message $message
            [void]$blockingIssues.Add($message)
            [void]$environmentVariableResults.Add([pscustomobject]@{
                schemaName = $schemaName
                displayName = $displayName
                status = 'would-update'
                message = $message
            })
        }
        elseif ($PSCmdlet.ShouldProcess($schemaName, "Update environment variable value in $targetEnvironmentUrl")) {
            Invoke-DataverseWebApiRequest -EnvironmentUrl $context.EnvironmentUrl -AccessToken $context.AccessToken -Method PATCH -RelativeUri "environmentvariablevalues($([string]$targetEnvironmentVariableValue.environmentVariableValueId))" -Body @{
                value = $expectedValue
            } | Out-Null

            $message = "Updated environment variable '$displayName' ($schemaName) using rules: $($resolution.AppliedRules -join ', ')."
            Write-StepResult -Level PASS -Message $message
            [void]$environmentVariableResults.Add([pscustomobject]@{
                schemaName = $schemaName
                displayName = $displayName
                status = 'updated'
                message = $message
            })
        }
        else {
            $message = "Skipped updating environment variable '$displayName' ($schemaName) because -WhatIf was supplied."
            Write-StepResult -Level INFO -Message $message
            [void]$environmentVariableResults.Add([pscustomobject]@{
                schemaName = $schemaName
                displayName = $displayName
                status = 'skipped'
                message = $message
            })
        }

        continue
    }

    $message = "Environment variable '$displayName' ($schemaName) differs from the source snapshot and no safe automatic replacement rule applied."
    Write-StepResult -Level WARN -Message $message
    [void]$blockingIssues.Add($message)
    [void]$environmentVariableResults.Add([pscustomobject]@{
        schemaName = $schemaName
        displayName = $displayName
        status = 'manual-review'
        message = $message
    })
}

$repairableLabs = if ($null -eq $artifactPackage.repairableLabs) { @() } else { @($artifactPackage.repairableLabs) }
Write-RepairChecklist -RepairableLabs $repairableLabs

$report = [ordered]@{
    schemaVersion              = 1
    evaluatedOnUtc             = [DateTime]::UtcNow.ToString('o')
    artifactPath               = $ArtifactPath
    sourceEnvironmentUrl       = [string]$artifactPackage.sourceEnvironmentUrl
    targetEnvironmentUrl       = $context.EnvironmentUrl
    validateOnly               = $ValidateOnly.IsPresent
    replacementRules           = @($replacementRules)
    connectionReferenceResults = @($connectionReferenceResults)
    environmentVariableResults = @($environmentVariableResults)
    repairableLabs             = $repairableLabs
}

$reportDirectory = Split-Path -Path $ReportPath -Parent
if (-not [string]::IsNullOrWhiteSpace($reportDirectory) -and -not (Test-Path -LiteralPath $reportDirectory -PathType Container)) {
    New-Item -Path $reportDirectory -ItemType Directory -Force | Out-Null
}

$report | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
Write-StepResult -Level PASS -Message "Saved facilitator binding repair report to '$ReportPath'."

if ($blockingIssues.Count -gt 0) {
    throw "Facilitator binding repair found unresolved issues.`n$($blockingIssues -join [System.Environment]::NewLine)"
}

Write-Section "Facilitator binding repair passed"
if ($ValidateOnly) {
    Write-StepResult -Level PASS -Message 'No unresolved repairable binding issues were found in validate-only mode.'
}
else {
    Write-StepResult -Level PASS -Message 'Environment-bound bindings are aligned with the captured gold-source artifact snapshot.'
}
