[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$ImportSolution
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Get-CsvRows {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $rows = @(Import-Csv -LiteralPath $Path)
    if ($rows.Count -lt 1) {
        throw "$Label must contain at least one data row."
    }

    return $rows
}

function Assert-CsvColumns {
    param(
        [Parameter(Mandatory = $true)]
        [object[]]$Rows,

        [Parameter(Mandatory = $true)]
        [string[]]$RequiredColumns,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $columns = @(($Rows | Select-Object -First 1 | Get-Member -MemberType NoteProperty).Name)
    $missingColumns = @($RequiredColumns | Where-Object { $_ -notin $columns })
    if ($missingColumns.Count -gt 0) {
        throw "$Label is missing required column(s): $($missingColumns -join ', ')"
    }

    Write-StepResult -Level PASS -Message "$Label contains the required columns: $($RequiredColumns -join ', ')."
}

function Assert-ZipLooksLikeSolutionPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
    try {
        if ($archive.Entries.Count -lt 1) {
            throw "Operative solution package '$Path' is empty."
        }

        $matchingEntry = $archive.Entries | Where-Object {
            $_.FullName -match '(?i)(customizations\.xml|solution\.xml|other/solution\.xml)'
        } | Select-Object -First 1

        if ($null -eq $matchingEntry) {
            throw "Operative solution package '$Path' does not look like a Dataverse solution ZIP."
        }
    }
    finally {
        $archive.Dispose()
    }

    Write-StepResult -Level PASS -Message "Operative package contains Dataverse solution metadata."
}

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
$environmentUrl = Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'

$operativeZipPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.OperativeSolutionZipPath)) -Label 'Operative solution package'
$jobRolesCsvPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.JobRolesCsvPath)) -Label 'Job roles CSV'
$evaluationCriteriaCsvPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.EvaluationCriteriaCsvPath)) -Label 'Evaluation criteria CSV'

Write-Section "Validating the Day 2 setup assets"
Assert-ZipLooksLikeSolutionPackage -Path $operativeZipPath

$jobRolesRows = Get-CsvRows -Path $jobRolesCsvPath -Label 'job-roles.csv'
$evaluationCriteriaRows = Get-CsvRows -Path $evaluationCriteriaCsvPath -Label 'evaluation-criteria.csv'

Assert-CsvColumns -Rows $jobRolesRows -RequiredColumns @('Job Title') -Label 'job-roles.csv'
Assert-CsvColumns -Rows $evaluationCriteriaRows -RequiredColumns @('Job Role', 'Criteria Name', 'Description', 'Weighting') -Label 'evaluation-criteria.csv'

$jobTitles = @($jobRolesRows | ForEach-Object { ([string]$_.'Job Title').Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
$unknownJobRoles = @($evaluationCriteriaRows | ForEach-Object { ([string]$_.'Job Role').Trim() } | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_) -and $_ -notin $jobTitles
} | Sort-Object -Unique)

if ($unknownJobRoles.Count -gt 0) {
    throw "evaluation-criteria.csv contains Job Role values that do not exist in job-roles.csv: $($unknownJobRoles -join ', ')"
}

Write-StepResult -Level PASS -Message "CSV relationships look consistent for Lab 13 imports."

if (-not $ImportSolution) {
    Write-Section "Validated assets without importing"
    Write-StepResult -Level INFO -Message "Student-ready mode keeps Lab 13 intact. Run this script again with -ImportSolution only when you want a separate facilitator demo environment pre-staged."
    return
}

Write-Section "Importing the Operative solution"
Require-Command -Name 'pac'
Write-StepResult -Level INFO -Message "Targeting the configured Power Platform environment '$environmentUrl' for solution import."
Invoke-NativeCommand -FilePath 'pac' -Arguments @('auth', 'list') -FailureMessage 'Unable to inspect Power Platform CLI auth profiles'
Invoke-NativeCommand -FilePath 'pac' -Arguments @('solution', 'import', '--environment', $environmentUrl, '--path', $operativeZipPath) -FailureMessage 'Operative solution import failed'
Write-StepResult -Level PASS -Message "Imported the Operative solution package."
Write-StepResult -Level WARN -Message "CSV import into Hiring Hub remains a manual or separately-scripted facilitator step so you can preserve the student Lab 13 walkthrough when needed."
