[CmdletBinding()]
param(
    [Parameter()]
    [string]$ConfigPath = (Join-Path -Path $PSScriptRoot -ChildPath 'workshop-config.json'),

    [Parameter()]
    [switch]$ValidateOnly,

    [Parameter()]
    [switch]$CreateDeviceRequestsList,

    [Parameter()]
    [switch]$CreateIncomingResumesLibrary
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

function Ensure-List {
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

function Ensure-FieldFromXml {
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

function Resolve-FieldInternalName {
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

function Set-DefaultViewFields {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ListTitle,

        [Parameter(Mandatory = $true)]
        [string[]]$FieldInternalNames
    )

    Set-PnPView -List $ListTitle -Identity 'All Items' -Fields $FieldInternalNames | Out-Null
    Write-StepResult -Level PASS -Message "Updated the default view for '$ListTitle'."
}

function Ensure-ListItem {
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

function Wait-ForSiteProvisioning {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl,

        [Parameter()]
        [int]$TimeoutSeconds = 300
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $tenantSite = Get-PnPTenantSite -Identity $SiteUrl -ErrorAction SilentlyContinue
        if ($null -ne $tenantSite) {
            return
        }

        Start-Sleep -Seconds 10
    }

    throw "SharePoint site '$SiteUrl' was not provisioned within $TimeoutSeconds seconds."
}

function Resolve-PnPLoginMode {
    param(
        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Value
    )

    if (Test-PlaceholderValue -Value $Value) {
        return 'OSLogin'
    }

    $normalizedValue = $Value.Trim()
    if ($normalizedValue -notin @('OSLogin', 'DeviceLogin', 'Interactive', 'CertificateThumbprint')) {
        throw "Config value 'SharePoint.PnPLoginMode' is not supported. Supported values: OSLogin, DeviceLogin, Interactive, CertificateThumbprint."
    }

    return $normalizedValue
}

function Connect-WorkshopPnPOnline {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [string]$Tenant,

        [Parameter(Mandatory = $true)]
        [string]$ClientId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('OSLogin', 'DeviceLogin', 'Interactive', 'CertificateThumbprint')]
        [string]$LoginMode,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$CertificateThumbprint,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    # Certificate auth is non-interactive — no fallback needed
    if ($LoginMode -eq 'CertificateThumbprint') {
        if ([string]::IsNullOrWhiteSpace($CertificateThumbprint)) {
            throw "A certificate thumbprint is required when SharePoint.PnPLoginMode is CertificateThumbprint."
        }
        Write-StepResult -Level INFO -Message "Connecting to $Label using certificate auth."
        Connect-PnPOnline -Url $Url -Tenant $Tenant -ClientId $ClientId -Thumbprint $CertificateThumbprint -ErrorAction Stop
        return
    }

    # Interactive auth waterfall: try the configured mode, fall back to DeviceLogin
    $methods = switch ($LoginMode) {
        'OSLogin'     { @('OSLogin', 'DeviceLogin') }
        'Interactive' { @('Interactive', 'DeviceLogin') }
        'DeviceLogin' { @('DeviceLogin') }
    }

    $lastError = $null
    foreach ($method in $methods) {
        try {
            Write-StepResult -Level INFO -Message "Connecting to $Label using PnP login mode '$method'."
            switch ($method) {
                'OSLogin' {
                    # WAM (Web Account Manager) — native Windows broker, no localhost redirect needed
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -OSLogin -ErrorAction Stop
                }
                'Interactive' {
                    # MSAL browser popup — requires http://127.0.0.1 redirect URI
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ErrorAction Stop
                }
                'DeviceLogin' {
                    # Device code flow — no redirect URI involved, requires -Tenant
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $Tenant -DeviceLogin -ErrorAction Stop
                }
            }
            return  # success
        }
        catch {
            $lastError = $_
            if ($methods.Count -gt 1 -and $method -ne $methods[-1]) {
                Write-StepResult -Level WARN -Message "$method failed for $Label`: $($_.Exception.Message). Trying fallback..."
            }
        }
    }

    # All methods exhausted
    throw "Unable to connect to $Label after trying $($methods -join ', '). Last error: $lastError"
}

function Get-DeviceStatusFieldXml {
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

function Get-TicketPriorityFieldXml {
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

function Get-TicketStatusFieldXml {
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

function Get-RequestStatusFieldXml {
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

Write-Section "Loading workshop configuration"
$config = Get-WorkshopConfig -Path $ConfigPath
Require-Module -Name 'PnP.PowerShell'

$tenantId = Get-RequiredString -Value ([string]$config.TenantId) -Name 'TenantId'
$sharePointConfig = $config.SharePoint
$siteUrl = Get-RequiredString -Value ([string]$sharePointConfig.SiteUrl) -Name 'SharePoint.SiteUrl'
$siteTitle = Get-RequiredString -Value ([string]$sharePointConfig.SiteTitle) -Name 'SharePoint.SiteTitle'
$siteAlias = Get-RequiredString -Value ([string]$sharePointConfig.SiteAlias) -Name 'SharePoint.SiteAlias'
$siteDescription = Get-RequiredString -Value ([string]$sharePointConfig.SiteDescription) -Name 'SharePoint.SiteDescription'
$adminUrl = Get-RequiredString -Value ([string]$sharePointConfig.AdminUrl) -Name 'SharePoint.AdminUrl'
$pnpClientId = [string]$sharePointConfig.PnPClientId
if (Test-PlaceholderValue -Value $pnpClientId) {
    throw "Config value 'SharePoint.PnPClientId' is required for modern PnP sign-in. Register or reuse an Entra ID app, then set its application (client) ID in workshop-config.json."
}

$pnpClientId = Get-RequiredString -Value $pnpClientId -Name 'SharePoint.PnPClientId'
$pnpLoginMode = Resolve-PnPLoginMode -Value ([string]$sharePointConfig.PnPLoginMode)
$pnpCertificateThumbprint = [string]$sharePointConfig.PnPCertificateThumbprint
if ($pnpLoginMode -eq 'CertificateThumbprint') {
    if (Test-PlaceholderValue -Value $pnpCertificateThumbprint) {
        throw "Config value 'SharePoint.PnPCertificateThumbprint' is required when SharePoint.PnPLoginMode is CertificateThumbprint."
    }

    $pnpCertificateThumbprint = Get-RequiredString -Value $pnpCertificateThumbprint -Name 'SharePoint.PnPCertificateThumbprint'
}

$shouldCreateDeviceRequestsList = if ($PSBoundParameters.ContainsKey('CreateDeviceRequestsList')) {
    $CreateDeviceRequestsList.IsPresent
}
else {
    [bool]$config.Day1.CreateDeviceRequestsList
}

$shouldCreateIncomingResumesLibrary = if ($PSBoundParameters.ContainsKey('CreateIncomingResumesLibrary')) {
    $CreateIncomingResumesLibrary.IsPresent
}
else {
    [bool]$config.Day1.CreateIncomingResumesLibrary
}

Write-Section "Connecting to SharePoint admin center"
Connect-WorkshopPnPOnline -Url $adminUrl -Tenant $tenantId -ClientId $pnpClientId -LoginMode $pnpLoginMode -CertificateThumbprint $pnpCertificateThumbprint -Label 'SharePoint admin center'

# Ensure custom app authentication is not disabled (blocks site creation in newer tenants)
try {
    Set-PnPTenant -DisableCustomAppAuthentication $false -ErrorAction SilentlyContinue
}
catch {
    Write-StepResult -Level WARN -Message "Could not verify DisableCustomAppAuthentication setting: $($_.Exception.Message)"
}

$existingSite = Get-PnPTenantSite -Identity $siteUrl -ErrorAction SilentlyContinue
if ($null -eq $existingSite) {
    if ($ValidateOnly) {
        throw "SharePoint site '$siteUrl' does not exist. Re-run without -ValidateOnly to create it."
    }

    Write-StepResult -Level INFO -Message "Creating SharePoint site '$siteTitle' because it does not exist yet."

    # Derive root tenant URL from admin URL (New-PnPSite needs root, not admin)
    $rootTenantUrl = $adminUrl -replace '-admin\.sharepoint\.com', '.sharepoint.com'

    try {
        # Connect to root tenant URL — New-PnPSite calls SPSiteManager/create which lives on the root site
        Connect-WorkshopPnPOnline -Url $rootTenantUrl -Tenant $tenantId -ClientId $pnpClientId -LoginMode $pnpLoginMode -CertificateThumbprint $pnpCertificateThumbprint -Label 'tenant root (for site creation)'
        New-PnPSite -Type TeamSiteWithoutMicrosoft365Group `
            -Title $siteTitle `
            -Url $siteUrl `
            -Description $siteDescription | Out-Null
    }
    catch {
        Write-StepResult -Level WARN -Message "New-PnPSite failed: $($_.Exception.Message). Trying New-PnPTenantSite..."

        # Fallback: use the classic admin cmdlet from admin URL
        Connect-WorkshopPnPOnline -Url $adminUrl -Tenant $tenantId -ClientId $pnpClientId -LoginMode $pnpLoginMode -CertificateThumbprint $pnpCertificateThumbprint -Label 'SharePoint admin center (fallback)'
        New-PnPTenantSite `
            -Title $siteTitle `
            -Url $siteUrl `
            -Template 'STS#3' `
            -Owner (Get-PnPProperty -ClientObject (Get-PnPWeb) -Property CurrentUser).Email `
            -TimeZone 13 `
            -Wait
    }

    Wait-ForSiteProvisioning -SiteUrl $siteUrl
}
else {
    Write-StepResult -Level PASS -Message "SharePoint site '$siteUrl' already exists."
}

Write-Section "Connecting to workshop SharePoint site"
Connect-WorkshopPnPOnline -Url $siteUrl -Tenant $tenantId -ClientId $pnpClientId -LoginMode $pnpLoginMode -CertificateThumbprint $pnpCertificateThumbprint -Label 'the workshop SharePoint site'

if ($ValidateOnly) {
    $devicesList = Get-PnPList -Identity 'Devices' -ErrorAction SilentlyContinue
    $ticketsList = Get-PnPList -Identity 'Tickets' -ErrorAction SilentlyContinue

    if ($null -eq $devicesList -or $null -eq $ticketsList) {
        throw "The workshop site exists, but one or more required lists (Devices, Tickets) are missing."
    }

    Write-StepResult -Level PASS -Message "Validated that the workshop site contains the Devices and Tickets lists."
    return
}

Write-Section "Ensuring Day 1 SharePoint artifacts"
Ensure-List -Title 'Devices' | Out-Null
Ensure-List -Title 'Tickets' | Out-Null

if ($shouldCreateDeviceRequestsList) {
    Ensure-List -Title 'Device Requests' | Out-Null
}

if ($shouldCreateIncomingResumesLibrary) {
    Ensure-List -Title 'Incoming Resumes' -Template 'DocumentLibrary' | Out-Null
}

Write-Section "Ensuring Devices schema"
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Manufacturer' -InternalName 'Manufacturer' -FieldXml '<Field Type="Text" DisplayName="Manufacturer" Name="Manufacturer" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Model' -InternalName 'DeviceModel' -FieldXml '<Field Type="Text" DisplayName="Model" Name="DeviceModel" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Asset Type' -InternalName 'AssetType' -FieldXml '<Field Type="Text" DisplayName="Asset Type" Name="AssetType" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Color' -InternalName 'Color' -FieldXml '<Field Type="Text" DisplayName="Color" Name="Color" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Serial Number' -InternalName 'SerialNumber' -FieldXml '<Field Type="Text" DisplayName="Serial Number" Name="SerialNumber" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Purchase Date' -InternalName 'PurchaseDate' -FieldXml '<Field Type="DateTime" DisplayName="Purchase Date" Name="PurchaseDate" Format="DateOnly" FriendlyDisplayFormat="Disabled" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Purchase Price' -InternalName 'PurchasePrice' -FieldXml '<Field Type="Currency" DisplayName="Purchase Price" Name="PurchasePrice" LCID="1033" Decimals="2" Min="0" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Order #' -InternalName 'OrderNumber' -FieldXml '<Field Type="Text" DisplayName="Order #" Name="OrderNumber" />'
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Status' -InternalName 'DeviceStatus' -FieldXml (Get-DeviceStatusFieldXml)
Ensure-FieldFromXml -ListTitle 'Devices' -DisplayName 'Image' -InternalName 'Image' -FieldXml '<Field Type="URL" DisplayName="Image" Name="Image" Format="Hyperlink" />'

$devicesManufacturerField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('Manufacturer') -Label 'Manufacturer'
$devicesModelField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('DeviceModel', 'Model') -Label 'Model'
$devicesAssetTypeField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('AssetType', 'Asset type', 'Asset Type') -Label 'Asset Type'
$devicesColorField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('Color') -Label 'Color'
$devicesSerialNumberField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('SerialNumber', 'Serial number', 'Serial Number') -Label 'Serial Number'
$devicesPurchaseDateField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('PurchaseDate', 'Purchase date', 'Purchase Date') -Label 'Purchase Date'
$devicesPurchasePriceField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('PurchasePrice', 'Purchase price', 'Purchase Price') -Label 'Purchase Price'
$devicesOrderNumberField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('OrderNumber', 'Order #', 'Order') -Label 'Order #'
$devicesStatusField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('DeviceStatus', 'Status') -Label 'Status'
$devicesImageField = Resolve-FieldInternalName -ListTitle 'Devices' -CandidateNames @('Image') -Label 'Image'

Set-DefaultViewFields -ListTitle 'Devices' -FieldInternalNames @(
    'LinkTitle',
    $devicesManufacturerField,
    $devicesModelField,
    $devicesAssetTypeField,
    $devicesColorField,
    $devicesSerialNumberField,
    $devicesPurchaseDateField,
    $devicesPurchasePriceField,
    $devicesOrderNumberField,
    $devicesStatusField,
    $devicesImageField
)

Write-Section "Ensuring Tickets schema"
Ensure-FieldFromXml -ListTitle 'Tickets' -DisplayName 'Description' -InternalName 'TicketDescription' -FieldXml '<Field Type="Note" DisplayName="Description" Name="TicketDescription" NumLines="6" RichText="FALSE" />'
Ensure-FieldFromXml -ListTitle 'Tickets' -DisplayName 'Priority' -InternalName 'TicketPriority' -FieldXml (Get-TicketPriorityFieldXml)
Ensure-FieldFromXml -ListTitle 'Tickets' -DisplayName 'Status' -InternalName 'TicketStatus' -FieldXml (Get-TicketStatusFieldXml)

$ticketsDescriptionField = Resolve-FieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketDescription', 'Description', 'Issue description') -Label 'Description'
$ticketsPriorityField = Resolve-FieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketPriority', 'Priority') -Label 'Priority'
$ticketsStatusField = Resolve-FieldInternalName -ListTitle 'Tickets' -CandidateNames @('TicketStatus', 'Status') -Label 'Status'

Set-DefaultViewFields -ListTitle 'Tickets' -FieldInternalNames @(
    'LinkTitle',
    $ticketsDescriptionField,
    $ticketsPriorityField,
    $ticketsStatusField,
    'Created'
)

if ($shouldCreateDeviceRequestsList) {
    Write-Section "Ensuring optional Device Requests schema"
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Requested By' -InternalName 'RequestedBy' -FieldXml '<Field Type="Text" DisplayName="Requested By" Name="RequestedBy" />'
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Manager Email' -InternalName 'ManagerEmail' -FieldXml '<Field Type="Text" DisplayName="Manager Email" Name="ManagerEmail" />'
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Comments' -InternalName 'RequestComments' -FieldXml '<Field Type="Note" DisplayName="Comments" Name="RequestComments" NumLines="6" RichText="FALSE" />'
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Device Model' -InternalName 'RequestedDeviceModel' -FieldXml '<Field Type="Text" DisplayName="Device Model" Name="RequestedDeviceModel" />'
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Device ID' -InternalName 'RequestedDeviceId' -FieldXml '<Field Type="Number" DisplayName="Device ID" Name="RequestedDeviceId" Decimals="0" Min="0" />'
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Request Status' -InternalName 'RequestStatus' -FieldXml (Get-RequestStatusFieldXml)
    Ensure-FieldFromXml -ListTitle 'Device Requests' -DisplayName 'Requested On' -InternalName 'RequestedOn' -FieldXml '<Field Type="DateTime" DisplayName="Requested On" Name="RequestedOn" Format="DateTime" FriendlyDisplayFormat="Disabled" />'
    Set-DefaultViewFields -ListTitle 'Device Requests' -FieldInternalNames @(
        'LinkTitle',
        'RequestedBy',
        'ManagerEmail',
        'RequestedDeviceModel',
        'RequestedDeviceId',
        'RequestStatus',
        'RequestedOn'
    )
}

Write-Section "Seeding sample Devices items"
foreach ($device in @($config.Day1.SampleDevices)) {
    $title = Get-RequiredString -Value ([string]$device.Title) -Name 'Day1.SampleDevices[].Title'
    $purchaseDate = Get-Date (Get-RequiredString -Value ([string]$device.PurchaseDate) -Name "Day1.SampleDevices[$title].PurchaseDate")

    $deviceValues = @{ Title = $title }
    $deviceValues[$devicesManufacturerField] = [string]$device.Manufacturer
    $deviceValues[$devicesModelField] = [string]$device.Model
    $deviceValues[$devicesAssetTypeField] = [string]$device.AssetType
    $deviceValues[$devicesColorField] = [string]$device.Color
    $deviceValues[$devicesSerialNumberField] = [string]$device.SerialNumber
    $deviceValues[$devicesPurchaseDateField] = $purchaseDate
    $deviceValues[$devicesPurchasePriceField] = [decimal]$device.PurchasePrice
    $deviceValues[$devicesOrderNumberField] = [string]$device.OrderNumber
    $deviceValues[$devicesStatusField] = Get-RequiredString -Value ([string]$device.Status) -Name "Day1.SampleDevices[$title].Status"

    if (-not [string]::IsNullOrWhiteSpace([string]$device.ImageUrl)) {
        $deviceValues[$devicesImageField] = [string]$device.ImageUrl
    }

    Ensure-ListItem -ListTitle 'Devices' -MatchField 'Title' -MatchValue $title -Values $deviceValues -Label 'sample device'
}

Write-Section "Seeding sample Tickets item"
$sampleTicket = $config.Day1.SampleTicket
$sampleTicketTitle = Get-RequiredString -Value ([string]$sampleTicket.Title) -Name 'Day1.SampleTicket.Title'
$ticketValues = @{ Title = $sampleTicketTitle }
$ticketValues[$ticketsDescriptionField] = Get-RequiredString -Value ([string]$sampleTicket.Description) -Name 'Day1.SampleTicket.Description'
$ticketValues[$ticketsPriorityField] = Get-RequiredString -Value ([string]$sampleTicket.Priority) -Name 'Day1.SampleTicket.Priority'
$ticketValues[$ticketsStatusField] = 'New'
Ensure-ListItem -ListTitle 'Tickets' -MatchField 'Title' -MatchValue $sampleTicketTitle -Values $ticketValues -Label 'sample ticket'

Write-Section "SharePoint initialization summary"
Write-StepResult -Level INFO -Message "The workshop site is ready for Lab 00 and the Day 1 SharePoint-dependent labs."
if (-not $shouldCreateDeviceRequestsList) {
    Write-StepResult -Level INFO -Message "Device Requests was intentionally left for Lab 09 so the student walkthrough still covers that exercise."
}
if (-not $shouldCreateIncomingResumesLibrary) {
    Write-StepResult -Level INFO -Message "Incoming Resumes was intentionally left for Lab 16 so the student walkthrough still covers that exercise."
}
