[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$ImportSolution,

    [Parameter()]
    [switch]$ImportBaseData,

    [Parameter()]
    [string]$EnvironmentUrl
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

function Get-WorkshopDay2SeedCandidates {
    return @(
        [pscustomobject]@{
            CandidateName         = 'Jordan Lee'
            Email                 = 'jordan@email.com'
            Phone                 = '555-0101'
            ResumeTitle           = 'Jordan Lee Resume'
            ResumeSummary         = 'Experienced Power Platform developer with strong Power Apps, Power Automate, connector, and Azure integration experience. Known for building enterprise solutions, troubleshooting complex flows, and collaborating with delivery teams.'
            JobRoleTitle          = 'Power Platform Developer'
            ApplicationDate       = '2026-01-15'
            InitialRecommendation = 894250003
        }
        [pscustomobject]@{
            CandidateName         = 'Casey Bennett'
            Email                 = 'casey@sample.com'
            Phone                 = '555-0102'
            ResumeTitle           = 'Casey Bennett Resume'
            ResumeSummary         = 'Consultant with strong client engagement, workshop facilitation, requirements gathering, project delivery, and training experience across Power Platform programs. Comfortable translating business needs into governed solutions.'
            JobRoleTitle          = 'Power Platform Consultant'
            ApplicationDate       = '2026-01-20'
            InitialRecommendation = 894250000
        }
    )
}

function Get-DataverseHeaders {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    return @{
        Authorization    = "Bearer $AccessToken"
        Accept           = 'application/json'
        'OData-Version'  = '4.0'
        'OData-MaxVersion' = '4.0'
    }
}

function ConvertTo-ODataStringLiteral {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    return ($Value -replace "'", "''")
}

function New-DataverseQueryUri {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter()]
        [string[]]$Select,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Filter
    )

    $queryParts = [System.Collections.Generic.List[string]]::new()
    if ($null -ne $Select -and $Select.Count -gt 0) {
        [void]$queryParts.Add('$select=' + [uri]::EscapeDataString(($Select -join ',')))
    }

    if (-not [string]::IsNullOrWhiteSpace($Filter)) {
        [void]$queryParts.Add('$filter=' + [uri]::EscapeDataString($Filter))
    }

    $normalizedEnvironmentUrl = $EnvironmentUrl.TrimEnd('/')
    $uri = "$normalizedEnvironmentUrl/api/data/v9.2/$EntitySetName"
    if ($queryParts.Count -gt 0) {
        $uri = "${uri}?$(($queryParts -join '&'))"
    }

    return $uri
}

function Invoke-DataverseGet {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter()]
        [string[]]$Select,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Filter
    )

    $uri = New-DataverseQueryUri -EnvironmentUrl $EnvironmentUrl -EntitySetName $EntitySetName -Select $Select -Filter $Filter
    return Invoke-RestMethod -Method GET -Uri $uri -Headers (Get-DataverseHeaders -AccessToken $AccessToken)
}

function Get-SingleDataverseRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter(Mandatory = $true)]
        [string[]]$Select,

        [Parameter(Mandatory = $true)]
        [string]$Filter,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $response = Invoke-DataverseGet -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName $EntitySetName -Select $Select -Filter $Filter
    $records = @()
    if ($null -ne $response -and $null -ne $response.value) {
        $records = @($response.value)
    }
    if ($records.Count -gt 1) {
        throw "Expected exactly one $Label record for filter '$Filter', but found $($records.Count)."
    }

    if ($records.Count -eq 0) {
        return $null
    }

    return $records[0]
}

function Invoke-DataverseCreate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter(Mandatory = $true)]
        [hashtable]$Body
    )

    $headers = Get-DataverseHeaders -AccessToken $AccessToken
    Invoke-RestMethod -Method POST -Uri "$($EnvironmentUrl.TrimEnd('/'))/api/data/v9.2/$EntitySetName" -Headers $headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 10) | Out-Null
}

function Invoke-DataverseUpdate {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter(Mandatory = $true)]
        [string]$RecordId,

        [Parameter(Mandatory = $true)]
        [hashtable]$Body
    )

    $headers = Get-DataverseHeaders -AccessToken $AccessToken
    Invoke-RestMethod -Method PATCH -Uri "$($EnvironmentUrl.TrimEnd('/'))/api/data/v9.2/$EntitySetName($RecordId)" -Headers $headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 10) | Out-Null
}

function Upsert-DataverseRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken,

        [Parameter(Mandatory = $true)]
        [string]$EntitySetName,

        [Parameter(Mandatory = $true)]
        [string]$PrimaryIdColumn,

        [Parameter(Mandatory = $true)]
        [string[]]$Select,

        [Parameter(Mandatory = $true)]
        [string]$Filter,

        [Parameter(Mandatory = $true)]
        [hashtable]$Body,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $record = Get-SingleDataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName $EntitySetName -Select $Select -Filter $Filter -Label $Label
    if ($null -eq $record) {
        Invoke-DataverseCreate -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName $EntitySetName -Body $Body
        $record = Get-SingleDataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName $EntitySetName -Select $Select -Filter $Filter -Label $Label
        if ($null -eq $record) {
            throw "Created $Label but could not retrieve it afterward."
        }

        Write-StepResult -Level PASS -Message "Created $Label."
    }
    else {
        $recordId = [string]$record.$PrimaryIdColumn
        Invoke-DataverseUpdate -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName $EntitySetName -RecordId $recordId -Body $Body
        Write-StepResult -Level PASS -Message "Updated $Label."
    }

    return $record
}

function Assert-OperativeSolutionPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $solution = Get-SingleDataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName 'solutions' -Select @('solutionid', 'uniquename', 'friendlyname') -Filter "uniquename eq 'Operative'" -Label 'Operative solution'
    if ($null -eq $solution) {
        throw "The Operative solution is not present in '$EnvironmentUrl'. Import the solution before importing the Day 2 base data."
    }

    Write-StepResult -Level PASS -Message "Confirmed that the Operative solution exists before base-data import."
}

function Import-WorkshopDay2BaseData {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [object[]]$JobRolesRows,

        [Parameter(Mandatory = $true)]
        [object[]]$EvaluationCriteriaRows
    )

    $tenantId = Get-RequiredString -Value ([string]$Config.TenantId) -Name 'TenantId'
    $clientId = Get-RequiredString -Value ([string]$Config.SharePoint.PnPClientId) -Name 'SharePoint.PnPClientId'
    $secretInfo = Resolve-ConfiguredClientSecret -Config $Config
    if ([string]::IsNullOrWhiteSpace($secretInfo.Value)) {
        throw "A client secret is required for Dataverse base-data import. Populate Identity.ClientSecret or the environment variable named by Identity.ClientSecretEnvVar, and make sure the workshop app has the Power Apps Service delegated permission with admin consent plus the one-time Power Platform app registration."
    }

    Write-Section "Preparing Dataverse access for base-data import"
    Ensure-DataverseApplicationUser -EnvironmentUrl $EnvironmentUrl -ApplicationId $clientId
    $accessToken = Get-DataverseAccessToken -TenantId $tenantId -ClientId $clientId -ClientSecret $secretInfo.Value -EnvironmentUrl $EnvironmentUrl
    Assert-OperativeSolutionPresent -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken

    Write-Section "Importing job roles"
    $jobRoleMap = @{}
    foreach ($row in $JobRolesRows) {
        $jobTitle = ([string]$row.'Job Title').Trim()
        if ([string]::IsNullOrWhiteSpace($jobTitle)) {
            continue
        }

        $filter = "ppa_jobtitle eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $jobTitle)
        $body = @{
            ppa_jobtitle       = $jobTitle
            ppa_description    = ([string]$row.Description).Trim()
            ppa_closedate      = ([string]$row.'Close Date').Trim()
            ppa_numberofhires  = [int]([string]$row.'Number of Hires')
        }

        $record = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'ppa_jobroles' -PrimaryIdColumn 'ppa_jobroleid' -Select @('ppa_jobroleid', 'ppa_jobtitle') -Filter $filter -Body $body -Label "job role '$jobTitle'"
        $jobRoleMap[$jobTitle] = [string]$record.ppa_jobroleid
    }

    Write-Section "Importing evaluation criteria"
    foreach ($row in $EvaluationCriteriaRows) {
        $criteriaName = ([string]$row.'Criteria Name').Trim()
        $jobRoleTitle = ([string]$row.'Job Role').Trim()
        if ([string]::IsNullOrWhiteSpace($criteriaName) -or [string]::IsNullOrWhiteSpace($jobRoleTitle)) {
            continue
        }

        if (-not $jobRoleMap.ContainsKey($jobRoleTitle)) {
            throw "Unable to resolve job role '$jobRoleTitle' for evaluation criterion '$criteriaName'."
        }

        $jobRoleId = $jobRoleMap[$jobRoleTitle]
        $filter = "_ppa_jobrole_value eq $jobRoleId and ppa_criterianame eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $criteriaName)
        $body = @{
            ppa_criterianame          = $criteriaName
            ppa_description           = ([string]$row.Description).Trim()
            ppa_weighting             = [decimal]::Parse(([string]$row.Weighting).Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
            'ppa_JobRole@odata.bind'  = "/ppa_jobroles($jobRoleId)"
        }

        [void](Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'ppa_evaluationcriterias' -PrimaryIdColumn 'ppa_evaluationcriteriaid' -Select @('ppa_evaluationcriteriaid', 'ppa_criterianame') -Filter $filter -Body $body -Label "evaluation criterion '$criteriaName' for '$jobRoleTitle'")
    }

    Write-Section "Importing sample candidates, resumes, and job applications"
    foreach ($seedCandidate in Get-WorkshopDay2SeedCandidates) {
        $candidateName = [string]$seedCandidate.CandidateName
        $candidateEmail = [string]$seedCandidate.Email
        $candidateFilter = "ppa_email eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $candidateEmail)
        $candidateBody = @{
            ppa_candidatename = $candidateName
            ppa_email         = $candidateEmail
            ppa_phone         = [string]$seedCandidate.Phone
        }

        $candidateRecord = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'ppa_candidates' -PrimaryIdColumn 'ppa_candidateid' -Select @('ppa_candidateid', 'ppa_candidatename', 'ppa_email') -Filter $candidateFilter -Body $candidateBody -Label "candidate '$candidateName'"
        $candidateId = [string]$candidateRecord.ppa_candidateid

        $resumeTitle = [string]$seedCandidate.ResumeTitle
        $resumeFilter = "_ppa_candidate_value eq $candidateId and ppa_resumetitle eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $resumeTitle)
        $resumeBody = @{
            ppa_resumetitle               = $resumeTitle
            ppa_sourceemailaddress        = $candidateEmail
            ppa_summary                   = [string]$seedCandidate.ResumeSummary
            ppa_uploaddate                = [string]$seedCandidate.ApplicationDate
            'ppa_Candidate@odata.bind'    = "/ppa_candidates($candidateId)"
        }

        $resumeRecord = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'ppa_resumes' -PrimaryIdColumn 'ppa_resumeid' -Select @('ppa_resumeid', 'ppa_resumetitle') -Filter $resumeFilter -Body $resumeBody -Label "resume '$resumeTitle'"
        $resumeId = [string]$resumeRecord.ppa_resumeid

        $jobRoleTitle = [string]$seedCandidate.JobRoleTitle
        if (-not $jobRoleMap.ContainsKey($jobRoleTitle)) {
            throw "Unable to resolve job role '$jobRoleTitle' for candidate '$candidateName'."
        }

        $jobRoleId = $jobRoleMap[$jobRoleTitle]
        $jobApplicationFilter = "_ppa_candidate_value eq $candidateId and _ppa_jobrole_value eq $jobRoleId and _ppa_resume_value eq $resumeId"
        $jobApplicationBody = @{
            ppa_applicationdate              = [string]$seedCandidate.ApplicationDate
            ppa_initialrecommendation        = [int]$seedCandidate.InitialRecommendation
            'ppa_Candidate@odata.bind'       = "/ppa_candidates($candidateId)"
            'ppa_JobRole@odata.bind'         = "/ppa_jobroles($jobRoleId)"
            'ppa_Resume@odata.bind'          = "/ppa_resumes($resumeId)"
        }

        [void](Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'ppa_jobapplications' -PrimaryIdColumn 'ppa_jobapplicationid' -Select @('ppa_jobapplicationid') -Filter $jobApplicationFilter -Body $jobApplicationBody -Label "job application for '$candidateName' and '$jobRoleTitle'")
    }
}

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath

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

if (-not $ImportSolution -and -not $ImportBaseData) {
    Write-Section "Validated assets without importing"
    Write-StepResult -Level INFO -Message "Student-ready mode keeps Lab 13 intact. Run this script again with -ImportSolution and/or -ImportBaseData only when you want a facilitator-owned demo or fallback environment pre-staged."
    return
}

$environmentUrl = if ($PSBoundParameters.ContainsKey('EnvironmentUrl')) {
    Get-RequiredString -Value $EnvironmentUrl -Name 'EnvironmentUrl'
}
else {
    Get-RequiredString -Value ([string]$config.EnvironmentUrl) -Name 'EnvironmentUrl'
}

Require-Command -Name 'pac'
Invoke-NativeCommand -FilePath 'pac' -Arguments @('auth', 'list') -FailureMessage 'Unable to inspect Power Platform CLI auth profiles'
Write-StepResult -Level INFO -Message "Import target comes from -EnvironmentUrl or config.EnvironmentUrl. pac auth provides tenant and account context only."

if ($ImportSolution) {
    Write-Section "Importing the Operative solution"
    Write-StepResult -Level INFO -Message "Targeting the Power Platform environment '$environmentUrl' for solution import."
    Invoke-NativeCommand -FilePath 'pac' -Arguments @('solution', 'import', '--environment', $environmentUrl, '--path', $operativeZipPath) -FailureMessage 'Operative solution import failed'
    Write-StepResult -Level PASS -Message "Imported the Operative solution package."
}

if ($ImportBaseData) {
    Write-Section "Importing Hiring Hub base data"
    Write-StepResult -Level INFO -Message "Targeting the Power Platform environment '$environmentUrl' for Hiring Hub base-data import."
    Import-WorkshopDay2BaseData -Config $config -EnvironmentUrl $environmentUrl -JobRolesRows $jobRolesRows -EvaluationCriteriaRows $evaluationCriteriaRows
    Write-StepResult -Level PASS -Message 'Imported the Day 2 Hiring Hub base data, including job roles, evaluation criteria, sample candidates, sample resumes, and sample job applications.'
}
