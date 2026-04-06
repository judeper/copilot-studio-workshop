# Reusable SharePoint site content initialization for FSI banking workshop.
# Dot-source this file after Common.ps1 and after establishing a PnP connection
# to the target site. Used by both Initialize-WorkshopSharePoint.ps1 (shared site)
# and Invoke-StudentEnvironmentProvisioning.ps1 (per-student sites).

function Ensure-WorkshopList {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter()]
        [ValidateSet('GenericList', 'DocumentLibrary')]
        [string]$Template = 'GenericList'
    )

    $list = Get-PnPList -Identity $Title -ErrorAction SilentlyContinue
    if ($null -ne $list) {
        Write-StepResult -Level PASS -Message "SharePoint artifact '$Title' already exists."
        return $list
    }

    New-PnPList -Title $Title -Template $Template -OnQuickLaunch | Out-Null
    Write-StepResult -Level PASS -Message "Created SharePoint artifact '$Title'."
    return Get-PnPList -Identity $Title -ErrorAction Stop
}

function Ensure-WorkshopFieldFromXml {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListTitle,

        [Parameter(Mandatory = $true)]
        [string]$DisplayName,

        [Parameter(Mandatory = $true)]
        [string]$InternalName,

        [Parameter(Mandatory = $true)]
        [string]$FieldXml
    )

    $existingField = Get-PnPField -List $ListTitle | Where-Object {
        $_.Title -eq $DisplayName -or $_.InternalName -eq $InternalName
    } | Select-Object -First 1

    if ($null -ne $existingField) {
        Write-StepResult -Level PASS -Message "Field '$DisplayName' already exists on '$ListTitle'."
        return
    }

    Add-PnPFieldFromXml -List $ListTitle -FieldXml $FieldXml | Out-Null
    Write-StepResult -Level PASS -Message "Created field '$DisplayName' on '$ListTitle'."
}

function Resolve-WorkshopFieldInternalName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListTitle,

        [Parameter(Mandatory = $true)]
        [string[]]$CandidateNames,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $field = Get-PnPField -List $ListTitle | Where-Object {
        $_.InternalName -in $CandidateNames -or $_.Title -in $CandidateNames
    } | Select-Object -First 1

    if ($null -eq $field) {
        throw "Unable to resolve the '$Label' field on '$ListTitle'. Checked: $($CandidateNames -join ', ')"
    }

    return $field.InternalName
}

function Set-WorkshopDefaultViewFields {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListTitle,

        [Parameter(Mandatory = $true)]
        [string[]]$FieldInternalNames
    )

    $views = Get-PnPView -List $ListTitle -ErrorAction SilentlyContinue
    $defaultView = $views | Where-Object { $_.DefaultView -eq $true } | Select-Object -First 1
    if (-not $defaultView) { $defaultView = $views | Select-Object -First 1 }
    if ($defaultView) {
        Set-PnPView -List $ListTitle -Identity $defaultView.Id -Fields $FieldInternalNames | Out-Null
        Write-StepResult -Level PASS -Message "Updated the default view for '$ListTitle'."
    } else {
        Write-StepResult -Level WARN -Message "Could not resolve a default view for list '$ListTitle'; skipping view field configuration."
    }
}

function Ensure-WorkshopListItem {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListTitle,

        [Parameter(Mandatory = $true)]
        [string]$MatchField,

        [Parameter(Mandatory = $true)]
        [string]$MatchValue,

        [Parameter(Mandatory = $true)]
        [hashtable]$Values,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $existingItem = Get-PnPListItem -List $ListTitle -PageSize 200 -Fields @($MatchField) | Where-Object {
        ([string]$_.FieldValues[$MatchField]) -eq $MatchValue
    } | Select-Object -First 1

    if ($null -ne $existingItem) {
        Write-StepResult -Level PASS -Message "$Label '$MatchValue' already exists in '$ListTitle'."
        return
    }

    Add-PnPListItem -List $ListTitle -Values $Values | Out-Null
    Write-StepResult -Level PASS -Message "Created $Label '$MatchValue' in '$ListTitle'."
}

# Schema XML generators
function Get-WorkshopAccountStatusFieldXml {
    return @'
<Field Type="Choice" DisplayName="Account Status" Name="AccountStatus" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>Active</CHOICE>
    <CHOICE>Frozen</CHOICE>
    <CHOICE>Closed</CHOICE>
  </CHOICES>
  <Default>Active</Default>
</Field>
'@
}

function Get-WorkshopRequestTypeFieldXml {
    return @'
<Field Type="Choice" DisplayName="Request Type" Name="RequestType" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>Dispute</CHOICE>
    <CHOICE>Address Change</CHOICE>
    <CHOICE>Fee Reversal</CHOICE>
  </CHOICES>
</Field>
'@
}

function Get-WorkshopRequestStatusFieldXml {
    return @'
<Field Type="Choice" DisplayName="Status" Name="RequestStatus" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>New</CHOICE>
    <CHOICE>In Progress</CHOICE>
    <CHOICE>Resolved</CHOICE>
  </CHOICES>
  <Default>New</Default>
</Field>
'@
}

function Get-WorkshopProductApplicationStatusFieldXml {
    return @'
<Field Type="Choice" DisplayName="Request Status" Name="RequestStatus" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>Pending</CHOICE>
    <CHOICE>Approved</CHOICE>
    <CHOICE>Rejected</CHOICE>
  </CHOICES>
  <Default>Pending</Default>
</Field>
'@
}

function Initialize-WorkshopSiteContent {
    <#
    .SYNOPSIS
        Creates all workshop lists, schemas, and sample data on the currently connected SharePoint site.
    .DESCRIPTION
        Call this AFTER Connect-PnPOnline to the target site. Creates Customer Accounts, Service Requests,
        Product Applications, and Loan Documents artifacts with full field schemas and sample data.
        Idempotent — safe to run multiple times on the same site.
    .PARAMETER Config
        The workshop config object (from Get-WorkshopConfig).
    .PARAMETER CreateProductApplicationsList
        Whether to create the Product Applications list (default: true for student sites).
    .PARAMETER CreateLoanDocumentsLibrary
        Whether to create the Loan Documents library (default: true for student sites).
    #>
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter()]
        [bool]$CreateProductApplicationsList = $true,

        [Parameter()]
        [bool]$CreateLoanDocumentsLibrary = $true
    )

    # Create lists
    Ensure-WorkshopList -Title 'Customer Accounts' | Out-Null
    Ensure-WorkshopList -Title 'Service Requests' | Out-Null

    if ($CreateProductApplicationsList) {
        Ensure-WorkshopList -Title 'Product Applications' | Out-Null
    }
    if ($CreateLoanDocumentsLibrary) {
        Ensure-WorkshopList -Title 'Loan Documents' -Template 'DocumentLibrary' | Out-Null
    }

    # Customer Accounts schema
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Account Number' -InternalName 'AccountNumber' -FieldXml '<Field Type="Text" DisplayName="Account Number" Name="AccountNumber" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Account Type' -InternalName 'AccountType' -FieldXml '<Field Type="Choice" DisplayName="Account Type" Name="AccountType" Format="Dropdown" FillInChoice="FALSE"><CHOICES><CHOICE>Checking</CHOICE><CHOICE>Savings</CHOICE><CHOICE>Credit Card</CHOICE></CHOICES></Field>'
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Current Balance' -InternalName 'CurrentBalance' -FieldXml '<Field Type="Currency" DisplayName="Current Balance" Name="CurrentBalance" LCID="1033" Decimals="2" Min="0" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Open Date' -InternalName 'OpenDate' -FieldXml '<Field Type="DateTime" DisplayName="Open Date" Name="OpenDate" Format="DateOnly" FriendlyDisplayFormat="Disabled" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Branch' -InternalName 'Branch' -FieldXml '<Field Type="Text" DisplayName="Branch" Name="Branch" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Account Status' -InternalName 'AccountStatus' -FieldXml (Get-WorkshopAccountStatusFieldXml)
    Ensure-WorkshopFieldFromXml -ListTitle 'Customer Accounts' -DisplayName 'Relationship Manager' -InternalName 'RelationshipManager' -FieldXml '<Field Type="Text" DisplayName="Relationship Manager" Name="RelationshipManager" />'

    $an = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('AccountNumber', 'Account Number') -Label 'Account Number'
    $atype = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('AccountType', 'Account Type') -Label 'Account Type'
    $bal = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('CurrentBalance', 'Current Balance') -Label 'Current Balance'
    $od = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('OpenDate', 'Open Date') -Label 'Open Date'
    $br = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('Branch') -Label 'Branch'
    $as = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('AccountStatus', 'Account Status') -Label 'Account Status'
    $rm = Resolve-WorkshopFieldInternalName -ListTitle 'Customer Accounts' -CandidateNames @('RelationshipManager', 'Relationship Manager') -Label 'Relationship Manager'

    Set-WorkshopDefaultViewFields -ListTitle 'Customer Accounts' -FieldInternalNames @('LinkTitle', $an, $atype, $bal, $od, $br, $as, $rm)

    # Service Requests schema
    Ensure-WorkshopFieldFromXml -ListTitle 'Service Requests' -DisplayName 'Description' -InternalName 'RequestDescription' -FieldXml '<Field Type="Note" DisplayName="Description" Name="RequestDescription" NumLines="6" RichText="FALSE" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Service Requests' -DisplayName 'Request Type' -InternalName 'RequestType' -FieldXml (Get-WorkshopRequestTypeFieldXml)
    Ensure-WorkshopFieldFromXml -ListTitle 'Service Requests' -DisplayName 'Status' -InternalName 'RequestStatus' -FieldXml (Get-WorkshopRequestStatusFieldXml)

    $rd = Resolve-WorkshopFieldInternalName -ListTitle 'Service Requests' -CandidateNames @('RequestDescription', 'Description') -Label 'Description'
    $rt = Resolve-WorkshopFieldInternalName -ListTitle 'Service Requests' -CandidateNames @('RequestType', 'Request Type') -Label 'Request Type'
    $rs = Resolve-WorkshopFieldInternalName -ListTitle 'Service Requests' -CandidateNames @('RequestStatus', 'Status') -Label 'Status'

    Set-WorkshopDefaultViewFields -ListTitle 'Service Requests' -FieldInternalNames @('LinkTitle', $rd, $rt, $rs, 'Created')

    # Product Applications schema
    if ($CreateProductApplicationsList) {
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Requested By' -InternalName 'RequestedBy' -FieldXml '<Field Type="Text" DisplayName="Requested By" Name="RequestedBy" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Manager Email' -InternalName 'ManagerEmail' -FieldXml '<Field Type="Text" DisplayName="Manager Email" Name="ManagerEmail" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Comments' -InternalName 'RequestComments' -FieldXml '<Field Type="Note" DisplayName="Comments" Name="RequestComments" NumLines="6" RichText="FALSE" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Account ID' -InternalName 'RequestedAccountId' -FieldXml '<Field Type="Number" DisplayName="Account ID" Name="RequestedAccountId" Decimals="0" Min="0" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Request Status' -InternalName 'RequestStatus' -FieldXml (Get-WorkshopProductApplicationStatusFieldXml)
        Ensure-WorkshopFieldFromXml -ListTitle 'Product Applications' -DisplayName 'Requested On' -InternalName 'RequestedOn' -FieldXml '<Field Type="DateTime" DisplayName="Requested On" Name="RequestedOn" Format="DateTime" FriendlyDisplayFormat="Disabled" />'
        Set-WorkshopDefaultViewFields -ListTitle 'Product Applications' -FieldInternalNames @('LinkTitle', 'RequestedBy', 'ManagerEmail', 'RequestComments', 'RequestedAccountId', 'RequestStatus', 'RequestedOn')
    }

    # Seed sample customer account data
    foreach ($account in @($Config.Day1.SampleAccounts)) {
        $title = Get-RequiredString -Value ([string]$account.Title) -Name 'Day1.SampleAccounts[].Title'
        $openDate = Get-Date (Get-RequiredString -Value ([string]$account.OpenDate) -Name "Day1.SampleAccounts[$title].OpenDate")

        $accountValues = @{ Title = $title }
        $accountValues[$an] = [string]$account.AccountNumber
        $accountValues[$atype] = [string]$account.AccountType
        $accountValues[$bal] = [decimal]$account.CurrentBalance
        $accountValues[$od] = $openDate
        $accountValues[$br] = [string]$account.Branch
        $accountValues[$as] = Get-RequiredString -Value ([string]$account.AccountStatus) -Name "Day1.SampleAccounts[$title].AccountStatus"
        $accountValues[$rm] = [string]$account.RelationshipManager

        Ensure-WorkshopListItem -ListTitle 'Customer Accounts' -MatchField 'Title' -MatchValue $title -Values $accountValues -Label 'sample account'
    }

    # Seed sample service request
    $sampleRequest = $Config.Day1.SampleServiceRequest
    $sampleRequestTitle = Get-RequiredString -Value ([string]$sampleRequest.Title) -Name 'Day1.SampleServiceRequest.Title'
    $requestValues = @{ Title = $sampleRequestTitle }
    $requestValues[$rd] = Get-RequiredString -Value ([string]$sampleRequest.Description) -Name 'Day1.SampleServiceRequest.Description'
    $requestValues[$rt] = Get-RequiredString -Value ([string]$sampleRequest.RequestType) -Name 'Day1.SampleServiceRequest.RequestType'
    $requestValues[$rs] = 'New'
    Ensure-WorkshopListItem -ListTitle 'Service Requests' -MatchField 'Title' -MatchValue $sampleRequestTitle -Values $requestValues -Label 'sample service request'

    Write-StepResult -Level PASS -Message 'Workshop site content initialized with full schema and sample data.'
}
