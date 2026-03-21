# Reusable SharePoint site content initialization.
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

    Set-PnPView -List $ListTitle -Identity 'All Items' -Fields $FieldInternalNames | Out-Null
    Write-StepResult -Level PASS -Message "Updated the default view for '$ListTitle'."
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
function Get-WorkshopDeviceStatusFieldXml {
    return @'
<Field Type="Choice" DisplayName="Status" Name="DeviceStatus" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>Available</CHOICE>
    <CHOICE>Requested</CHOICE>
    <CHOICE>Retired</CHOICE>
  </CHOICES>
  <Default>Available</Default>
</Field>
'@
}

function Get-WorkshopTicketPriorityFieldXml {
    return @'
<Field Type="Choice" DisplayName="Priority" Name="TicketPriority" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>Low</CHOICE>
    <CHOICE>Normal</CHOICE>
    <CHOICE>High</CHOICE>
  </CHOICES>
  <Default>Normal</Default>
</Field>
'@
}

function Get-WorkshopTicketStatusFieldXml {
    return @'
<Field Type="Choice" DisplayName="Status" Name="TicketStatus" Format="Dropdown" FillInChoice="FALSE">
  <CHOICES>
    <CHOICE>New</CHOICE>
    <CHOICE>In Progress</CHOICE>
    <CHOICE>Resolved</CHOICE>
  </CHOICES>
  <Default>New</Default>
</Field>
'@
}

function Get-WorkshopRequestStatusFieldXml {
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
        Call this AFTER Connect-PnPOnline to the target site. Creates Devices, Tickets,
        Device Requests, and Incoming Resumes artifacts with full field schemas and sample data.
        Idempotent — safe to run multiple times on the same site.
    .PARAMETER Config
        The workshop config object (from Get-WorkshopConfig).
    .PARAMETER CreateDeviceRequestsList
        Whether to create the Device Requests list (default: true for student sites).
    .PARAMETER CreateIncomingResumesLibrary
        Whether to create the Incoming Resumes library (default: true for student sites).
    #>
    param(
        [Parameter(Mandatory = $true)]
        [psobject]$Config,

        [Parameter()]
        [bool]$CreateDeviceRequestsList = $true,

        [Parameter()]
        [bool]$CreateIncomingResumesLibrary = $true
    )

    # Create lists
    Ensure-WorkshopList -Title 'Devices' | Out-Null
    Ensure-WorkshopList -Title 'Tickets' | Out-Null

    if ($CreateDeviceRequestsList) {
        Ensure-WorkshopList -Title 'Device Requests' | Out-Null
    }
    if ($CreateIncomingResumesLibrary) {
        Ensure-WorkshopList -Title 'Incoming Resumes' -Template 'DocumentLibrary' | Out-Null
    }

    # Devices schema
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Manufacturer' -InternalName 'Manufacturer' -FieldXml '<Field Type="Text" DisplayName="Manufacturer" Name="Manufacturer" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Model' -InternalName 'DeviceModel' -FieldXml '<Field Type="Text" DisplayName="Model" Name="DeviceModel" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Asset Type' -InternalName 'AssetType' -FieldXml '<Field Type="Text" DisplayName="Asset Type" Name="AssetType" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Color' -InternalName 'Color' -FieldXml '<Field Type="Text" DisplayName="Color" Name="Color" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Serial Number' -InternalName 'SerialNumber' -FieldXml '<Field Type="Text" DisplayName="Serial Number" Name="SerialNumber" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Purchase Date' -InternalName 'PurchaseDate' -FieldXml '<Field Type="DateTime" DisplayName="Purchase Date" Name="PurchaseDate" Format="DateOnly" FriendlyDisplayFormat="Disabled" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Purchase Price' -InternalName 'PurchasePrice' -FieldXml '<Field Type="Currency" DisplayName="Purchase Price" Name="PurchasePrice" LCID="1033" Decimals="2" Min="0" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Order #' -InternalName 'OrderNumber' -FieldXml '<Field Type="Text" DisplayName="Order #" Name="OrderNumber" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Status' -InternalName 'DeviceStatus' -FieldXml (Get-WorkshopDeviceStatusFieldXml)
    Ensure-WorkshopFieldFromXml -ListTitle 'Devices' -DisplayName 'Image' -InternalName 'Image' -FieldXml '<Field Type="URL" DisplayName="Image" Name="Image" Format="Hyperlink" />'

    $mfr = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('Manufacturer') -Label 'Manufacturer'
    $mdl = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('DeviceModel', 'Model') -Label 'Model'
    $at = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('AssetType', 'Asset type', 'Asset Type') -Label 'Asset Type'
    $clr = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('Color') -Label 'Color'
    $sn = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('SerialNumber', 'Serial number', 'Serial Number') -Label 'Serial Number'
    $pd = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('PurchaseDate', 'Purchase date', 'Purchase Date') -Label 'Purchase Date'
    $pp = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('PurchasePrice', 'Purchase price', 'Purchase Price') -Label 'Purchase Price'
    $on = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('OrderNumber', 'Order #', 'Order') -Label 'Order #'
    $st = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('DeviceStatus', 'Status') -Label 'Status'
    $img = Resolve-WorkshopFieldInternalName -ListTitle 'Devices' -CandidateNames @('Image') -Label 'Image'

    Set-WorkshopDefaultViewFields -ListTitle 'Devices' -FieldInternalNames @('LinkTitle', $mfr, $mdl, $at, $clr, $sn, $pd, $pp, $on, $st, $img)

    # Tickets schema
    Ensure-WorkshopFieldFromXml -ListTitle 'Tickets' -DisplayName 'Description' -InternalName 'TicketDescription' -FieldXml '<Field Type="Note" DisplayName="Description" Name="TicketDescription" NumLines="6" RichText="FALSE" />'
    Ensure-WorkshopFieldFromXml -ListTitle 'Tickets' -DisplayName 'Priority' -InternalName 'TicketPriority' -FieldXml (Get-WorkshopTicketPriorityFieldXml)
    Ensure-WorkshopFieldFromXml -ListTitle 'Tickets' -DisplayName 'Status' -InternalName 'TicketStatus' -FieldXml (Get-WorkshopTicketStatusFieldXml)

    $td = Resolve-WorkshopFieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketDescription', 'Description', 'Issue description') -Label 'Description'
    $tp = Resolve-WorkshopFieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketPriority', 'Priority') -Label 'Priority'
    $ts = Resolve-WorkshopFieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketStatus', 'Status') -Label 'Status'

    Set-WorkshopDefaultViewFields -ListTitle 'Tickets' -FieldInternalNames @('LinkTitle', $td, $tp, $ts, 'Created')

    # Device Requests schema
    if ($CreateDeviceRequestsList) {
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Requested By' -InternalName 'RequestedBy' -FieldXml '<Field Type="Text" DisplayName="Requested By" Name="RequestedBy" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Manager Email' -InternalName 'ManagerEmail' -FieldXml '<Field Type="Text" DisplayName="Manager Email" Name="ManagerEmail" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Comments' -InternalName 'RequestComments' -FieldXml '<Field Type="Note" DisplayName="Comments" Name="RequestComments" NumLines="6" RichText="FALSE" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Device Model' -InternalName 'RequestedDeviceModel' -FieldXml '<Field Type="Text" DisplayName="Device Model" Name="RequestedDeviceModel" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Device ID' -InternalName 'RequestedDeviceId' -FieldXml '<Field Type="Number" DisplayName="Device ID" Name="RequestedDeviceId" Decimals="0" Min="0" />'
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Request Status' -InternalName 'RequestStatus' -FieldXml (Get-WorkshopRequestStatusFieldXml)
        Ensure-WorkshopFieldFromXml -ListTitle 'Device Requests' -DisplayName 'Requested On' -InternalName 'RequestedOn' -FieldXml '<Field Type="DateTime" DisplayName="Requested On" Name="RequestedOn" Format="DateTime" FriendlyDisplayFormat="Disabled" />'
        Set-WorkshopDefaultViewFields -ListTitle 'Device Requests' -FieldInternalNames @('LinkTitle', 'RequestedBy', 'ManagerEmail', 'RequestedDeviceModel', 'RequestedDeviceId', 'RequestStatus', 'RequestedOn')
    }

    # Seed sample data
    foreach ($device in @($Config.Day1.SampleDevices)) {
        $title = Get-RequiredString -Value ([string]$device.Title) -Name 'Day1.SampleDevices[].Title'
        $purchaseDate = Get-Date (Get-RequiredString -Value ([string]$device.PurchaseDate) -Name "Day1.SampleDevices[$title].PurchaseDate")

        $deviceValues = @{ Title = $title }
        $deviceValues[$mfr] = [string]$device.Manufacturer
        $deviceValues[$mdl] = [string]$device.Model
        $deviceValues[$at] = [string]$device.AssetType
        $deviceValues[$clr] = [string]$device.Color
        $deviceValues[$sn] = [string]$device.SerialNumber
        $deviceValues[$pd] = $purchaseDate
        $deviceValues[$pp] = [decimal]$device.PurchasePrice
        $deviceValues[$on] = [string]$device.OrderNumber
        $deviceValues[$st] = Get-RequiredString -Value ([string]$device.Status) -Name "Day1.SampleDevices[$title].Status"

        if (-not [string]::IsNullOrWhiteSpace([string]$device.ImageUrl)) {
            $deviceValues[$img] = [string]$device.ImageUrl
        }

        Ensure-WorkshopListItem -ListTitle 'Devices' -MatchField 'Title' -MatchValue $title -Values $deviceValues -Label 'sample device'
    }

    $sampleTicket = $Config.Day1.SampleTicket
    $sampleTicketTitle = Get-RequiredString -Value ([string]$sampleTicket.Title) -Name 'Day1.SampleTicket.Title'
    $ticketValues = @{ Title = $sampleTicketTitle }
    $ticketValues[$td] = Get-RequiredString -Value ([string]$sampleTicket.Description) -Name 'Day1.SampleTicket.Description'
    $ticketValues[$tp] = Get-RequiredString -Value ([string]$sampleTicket.Priority) -Name 'Day1.SampleTicket.Priority'
    $ticketValues[$ts] = 'New'
    Ensure-WorkshopListItem -ListTitle 'Tickets' -MatchField 'Title' -MatchValue $sampleTicketTitle -Values $ticketValues -Label 'sample ticket'

    Write-StepResult -Level PASS -Message 'Workshop site content initialized with full schema and sample data.'
}
