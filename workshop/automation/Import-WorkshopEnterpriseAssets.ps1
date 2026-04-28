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
            throw "WoodgroveLending solution package '$Path' is empty."
        }

        $matchingEntry = $archive.Entries | Where-Object {
            $_.FullName -match '(?i)(customizations\.xml|solution\.xml|other/solution\.xml)'
        } | Select-Object -First 1

        if ($null -eq $matchingEntry) {
            throw "WoodgroveLending solution package '$Path' does not look like a Dataverse solution ZIP."
        }
    }
    finally {
        $archive.Dispose()
    }

    Write-StepResult -Level PASS -Message "WoodgroveLending package contains Dataverse solution metadata."
}

function Get-WorkshopDay2SeedApplicants {
    return @(
        [pscustomobject]@{
            ApplicantName     = 'Morgan Chen'
            Email             = 'morgan.chen@email.com'
            Phone             = '555-0201'
            AnnualIncome      = 92000
            EmploymentStatus  = 894250000  # Employed
            DocumentName      = 'Morgan Chen Financial Summary'
            DocumentType      = 894250000  # Financial Summary
            LoanTypeName      = 'Personal Loan'
            ApplicationDate   = '2026-01-15'
            RequestedAmount   = 25000
            Status            = 894250000  # Submitted
            AssignedOfficer   = 'James Park'
        }
        [pscustomobject]@{
            ApplicantName     = 'Alex Rivera'
            Email             = 'alex.rivera@email.com'
            Phone             = '555-0202'
            AnnualIncome      = 145000
            EmploymentStatus  = 894250000  # Employed
            DocumentName      = 'Alex Rivera Financial Summary'
            DocumentType      = 894250000  # Financial Summary
            LoanTypeName      = 'Mortgage'
            ApplicationDate   = '2026-01-20'
            RequestedAmount   = 450000
            Status            = 894250001  # Under Review
            AssignedOfficer   = 'Lisa Chen'
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
    return Invoke-RestMethod -Method GET -Uri $uri -Headers (Get-DataverseHeaders -AccessToken $AccessToken) -TimeoutSec 120
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
    Invoke-RestMethod -Method POST -Uri "$($EnvironmentUrl.TrimEnd('/'))/api/data/v9.2/$EntitySetName" -Headers $headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 10) -TimeoutSec 120 | Out-Null
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
    Invoke-RestMethod -Method PATCH -Uri "$($EnvironmentUrl.TrimEnd('/'))/api/data/v9.2/$EntitySetName($RecordId)" -Headers $headers -ContentType 'application/json' -Body ($Body | ConvertTo-Json -Depth 10) -TimeoutSec 120 | Out-Null
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

function Assert-EnterpriseSolutionPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [string]$AccessToken
    )

    $solution = Get-SingleDataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $AccessToken -EntitySetName 'solutions' -Select @('solutionid', 'uniquename', 'friendlyname') -Filter "uniquename eq 'WoodgroveLending'" -Label 'WoodgroveLending solution'
    if ($null -eq $solution) {
        throw "The WoodgroveLending solution is not present in '$EnvironmentUrl'. Import the solution before importing the Day 2 base data."
    }

    Write-StepResult -Level PASS -Message "Confirmed that the WoodgroveLending solution exists before base-data import."
}

function Import-WorkshopDay2BaseData {
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter(Mandatory = $true)]
        [string]$EnvironmentUrl,

        [Parameter(Mandatory = $true)]
        [object[]]$LoanTypeRows,

        [Parameter(Mandatory = $true)]
        [object[]]$AssessmentCriteriaRows
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
    Assert-EnterpriseSolutionPresent -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken

    Write-Section "Importing loan types"
    $loanTypeMap = @{}
    foreach ($row in $LoanTypeRows) {
        $loanTypeName = ([string]$row.'Loan Type Name').Trim()
        if ([string]::IsNullOrWhiteSpace($loanTypeName)) {
            continue
        }

        $filter = "wgb_loantypename eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $loanTypeName)
        $body = @{
            wgb_loantypename   = $loanTypeName
            wgb_description    = ([string]$row.Description).Trim()
            wgb_maximumterm    = [int]([string]$row.'Maximum Term (Months)')
            wgb_minimumamount  = [decimal]::Parse(([string]$row.'Minimum Amount').Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
            wgb_maximumamount  = [decimal]::Parse(([string]$row.'Maximum Amount').Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
        }

        $record = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'wgb_loantypes' -PrimaryIdColumn 'wgb_loantypeid' -Select @('wgb_loantypeid', 'wgb_loantypename') -Filter $filter -Body $body -Label "loan type '$loanTypeName'"
        $loanTypeMap[$loanTypeName] = [string]$record.wgb_loantypeid
    }

    Write-Section "Importing assessment criteria"
    foreach ($row in $AssessmentCriteriaRows) {
        $criteriaName = ([string]$row.'Criteria Name').Trim()
        $loanTypeName = ([string]$row.'Loan Type').Trim()
        if ([string]::IsNullOrWhiteSpace($criteriaName) -or [string]::IsNullOrWhiteSpace($loanTypeName)) {
            continue
        }

        if (-not $loanTypeMap.ContainsKey($loanTypeName)) {
            throw "Unable to resolve loan type '$loanTypeName' for assessment criterion '$criteriaName'."
        }

        $loanTypeId = $loanTypeMap[$loanTypeName]
        $filter = "_wgb_loantype_value eq $loanTypeId and wgb_criterianame eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $criteriaName)
        $body = @{
            wgb_criterianame            = $criteriaName
            wgb_description             = ([string]$row.Description).Trim()
            wgb_weighting               = [decimal]::Parse(([string]$row.Weighting).Trim(), [System.Globalization.CultureInfo]::InvariantCulture)
            'wgb_LoanType@odata.bind'   = "/wgb_loantypes($loanTypeId)"
        }

        [void](Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'wgb_assessmentcriterias' -PrimaryIdColumn 'wgb_assessmentcriteriaid' -Select @('wgb_assessmentcriteriaid', 'wgb_criterianame') -Filter $filter -Body $body -Label "assessment criterion '$criteriaName' for '$loanTypeName'")
    }

    Write-Section "Importing sample applicants, application documents, and loan applications"
    foreach ($seedApplicant in Get-WorkshopDay2SeedApplicants) {
        $applicantName = [string]$seedApplicant.ApplicantName
        $applicantEmail = [string]$seedApplicant.Email
        $applicantFilter = "wgb_email eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $applicantEmail)
        $applicantBody = @{
            wgb_applicantname    = $applicantName
            wgb_email            = $applicantEmail
            wgb_phone            = [string]$seedApplicant.Phone
            wgb_annualincome     = [decimal]$seedApplicant.AnnualIncome
            wgb_employmentstatus = [int]$seedApplicant.EmploymentStatus
        }

        $applicantRecord = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'wgb_applicants' -PrimaryIdColumn 'wgb_applicantid' -Select @('wgb_applicantid', 'wgb_applicantname', 'wgb_email') -Filter $applicantFilter -Body $applicantBody -Label "applicant '$applicantName'"
        $applicantId = [string]$applicantRecord.wgb_applicantid

        $documentName = [string]$seedApplicant.DocumentName
        $documentFilter = "_wgb_applicant_value eq $applicantId and wgb_documentname eq '{0}'" -f (ConvertTo-ODataStringLiteral -Value $documentName)
        $documentBody = @{
            wgb_documentname                = $documentName
            wgb_documenttype                = [int]$seedApplicant.DocumentType
            wgb_uploaddate                  = [string]$seedApplicant.ApplicationDate
            'wgb_Applicant@odata.bind'      = "/wgb_applicants($applicantId)"
        }

        $documentRecord = Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'wgb_applicationdocuments' -PrimaryIdColumn 'wgb_applicationdocumentid' -Select @('wgb_applicationdocumentid', 'wgb_documentname') -Filter $documentFilter -Body $documentBody -Label "application document '$documentName'"
        $documentId = [string]$documentRecord.wgb_applicationdocumentid

        $loanTypeName = [string]$seedApplicant.LoanTypeName
        if (-not $loanTypeMap.ContainsKey($loanTypeName)) {
            throw "Unable to resolve loan type '$loanTypeName' for applicant '$applicantName'."
        }

        $loanTypeId = $loanTypeMap[$loanTypeName]
        $loanApplicationFilter = "_wgb_applicant_value eq $applicantId and _wgb_loantype_value eq $loanTypeId and _wgb_applicationdocument_value eq $documentId"
        $loanApplicationBody = @{
            wgb_applicationdate                  = [string]$seedApplicant.ApplicationDate
            wgb_requestedamount                  = [decimal]$seedApplicant.RequestedAmount
            wgb_status                           = [int]$seedApplicant.Status
            wgb_assignedofficer                  = [string]$seedApplicant.AssignedOfficer
            'wgb_Applicant@odata.bind'           = "/wgb_applicants($applicantId)"
            'wgb_LoanType@odata.bind'            = "/wgb_loantypes($loanTypeId)"
            'wgb_ApplicationDocument@odata.bind'  = "/wgb_applicationdocuments($documentId)"
        }

        [void](Upsert-DataverseRecord -EnvironmentUrl $EnvironmentUrl -AccessToken $accessToken -EntitySetName 'wgb_loanapplications' -PrimaryIdColumn 'wgb_loanapplicationid' -Select @('wgb_loanapplicationid') -Filter $loanApplicationFilter -Body $loanApplicationBody -Label "loan application for '$applicantName' and '$loanTypeName'")
    }
}

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
Assert-FacilitatorOnlyEnvironment -Config $config

$enterpriseZipPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.EnterpriseSolutionZipPath)) -Label 'WoodgroveLending solution package'
$jobRolesCsvPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.LoanTypesCsvPath)) -Label 'Loan types CSV'
$evaluationCriteriaCsvPath = Assert-FileExists -Path (Resolve-ConfiguredPath -ConfigPath $ConfigPath -ConfiguredPath ([string]$config.Day2.AssessmentCriteriaCsvPath)) -Label 'Assessment criteria CSV'

Write-Section "Validating the Day 2 setup assets"
Assert-ZipLooksLikeSolutionPackage -Path $enterpriseZipPath

$loanTypeRows = Get-CsvRows -Path $jobRolesCsvPath -Label 'loan-types.csv'
$assessmentCriteriaRows = Get-CsvRows -Path $evaluationCriteriaCsvPath -Label 'assessment-criteria.csv'

Assert-CsvColumns -Rows $loanTypeRows -RequiredColumns @('Loan Type Name') -Label 'loan-types.csv'
Assert-CsvColumns -Rows $assessmentCriteriaRows -RequiredColumns @('Loan Type', 'Criteria Name', 'Description', 'Weighting') -Label 'assessment-criteria.csv'

$loanTypeNames = @($loanTypeRows | ForEach-Object { ([string]$_.'Loan Type Name').Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique)
$unknownLoanTypes = @($assessmentCriteriaRows | ForEach-Object { ([string]$_.'Loan Type').Trim() } | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_) -and $_ -notin $loanTypeNames
} | Sort-Object -Unique)

if ($unknownLoanTypes.Count -gt 0) {
    throw "assessment-criteria.csv contains Loan Type values that do not exist in loan-types.csv: $($unknownLoanTypes -join ', ')"
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
    Write-Section "Importing the WoodgroveLending solution"
    Write-StepResult -Level INFO -Message "Targeting the Power Platform environment '$environmentUrl' for solution import."
    Invoke-NativeCommand -FilePath 'pac' -Arguments @('solution', 'import', '--environment', $environmentUrl, '--path', $enterpriseZipPath) -FailureMessage 'WoodgroveLending solution import failed'
    Write-StepResult -Level PASS -Message "Imported the WoodgroveLending solution package."
}

if ($ImportBaseData) {
    Write-Section "Importing Woodgrove Lending Hub base data"
    Write-StepResult -Level INFO -Message "Targeting the Power Platform environment '$environmentUrl' for Woodgrove Lending Hub base-data import."
    Import-WorkshopDay2BaseData -Config $config -EnvironmentUrl $environmentUrl -LoanTypeRows $loanTypeRows -AssessmentCriteriaRows $assessmentCriteriaRows
    Write-StepResult -Level PASS -Message 'Imported the Day 2 Woodgrove Lending Hub base data, including loan types, assessment criteria, sample applicants, application documents, and loan applications.'
}

Write-Section "Environment status"
if ($ImportSolution -and $ImportBaseData) {
    Write-StepResult -Level PASS -Message 'Environment status: DEMO-READY (solution + Lab 13 base data imported in a single run).'
}
elseif ($ImportBaseData) {
    Write-StepResult -Level PASS -Message 'Environment status: DEMO-READY (solution + Lab 13 base data imported).'
}
elseif ($ImportSolution) {
    Write-StepResult -Level WARN -Message 'Environment status: SOLUTION-ONLY (Lab 13 base data NOT imported — run with -ImportBaseData for demo-ready).'
}
