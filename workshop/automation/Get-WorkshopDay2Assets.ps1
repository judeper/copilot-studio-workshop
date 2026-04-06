[CmdletBinding()]
param(
    [Parameter()]
    [string]$DestinationDirectory = [System.IO.Path]::GetFullPath((Join-Path -Path $PSScriptRoot -ChildPath '..\assets')),

    [Parameter()]
    [string]$Branch = 'main',

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

$sourceOwner = 'judeper'
$sourceRepository = 'copilot-studio-workshop'
$sourceAssetPath = 'workshop/assets'
$assetDefinitions = @(
    [pscustomobject]@{
        Name = 'WoodgroveLending_1_0_0_0.zip'
        Type = 'Zip'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'loan-types.csv'
        Type = 'Csv'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'assessment-criteria.csv'
        Type = 'Csv'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'MORGAN CHEN (FICTITIOUS).pdf'
        Type = 'Binary'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'ALEX RIVERA (FICTITIOUS).pdf'
        Type = 'Binary'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'Loan_Assessment_Template.docx'
        Type = 'Binary'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'Enterprise07StarterTemplate.zip'
        Type = 'Zip'
        SourcePath = $sourceAssetPath
    },
    [pscustomobject]@{
        Name = 'Enterprise09StarterSolution.zip'
        Type = 'Zip'
        SourcePath = $sourceAssetPath
    }
)

function Get-AssetDownloadUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Owner,

        [Parameter(Mandatory = $true)]
        [string]$Repository,

        [Parameter(Mandatory = $true)]
        [string]$BranchName,

        [Parameter(Mandatory = $true)]
        [string]$AssetPath,

        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    $encodedSegments = @($AssetPath -split '/' | ForEach-Object { [System.Uri]::EscapeDataString($_) })
    $encodedPath = ($encodedSegments + [System.Uri]::EscapeDataString($FileName)) -join '/'
    return "https://raw.githubusercontent.com/$Owner/$Repository/$BranchName/$encodedPath"
}

function Assert-NonEmptyFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label was not found at '$Path'."
    }

    $fileInfo = Get-Item -LiteralPath $Path
    if ($fileInfo.Length -le 0) {
        throw "$Label at '$Path' is empty."
    }

    Write-StepResult -Level PASS -Message "$Label exists and is $($fileInfo.Length) bytes."
    return $fileInfo
}

function Assert-CsvCanParse {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Label
    )

    $headerLine = Get-Content -LiteralPath $Path -TotalCount 1
    if ([string]::IsNullOrWhiteSpace($headerLine)) {
        throw "$Label is missing a CSV header row."
    }

    $rows = @(Import-Csv -LiteralPath $Path)
    Write-StepResult -Level PASS -Message "$Label parsed successfully as CSV with $($rows.Count) data row(s)."
}

function Save-WorkshopAsset {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Asset,

        [Parameter(Mandatory = $true)]
        [string]$TargetDirectory,

        [Parameter(Mandatory = $true)]
        [string]$DownloadUrl,

        [Parameter(Mandatory = $true)]
        [bool]$Overwrite
    )

    $destinationPath = Join-Path -Path $TargetDirectory -ChildPath $Asset.Name
    if ((Test-Path -LiteralPath $destinationPath -PathType Leaf) -and -not $Overwrite) {
        Write-StepResult -Level INFO -Message "Using existing $($Asset.Name) at '$destinationPath'."
        return $destinationPath
    }

    $temporaryPath = "$destinationPath.download"
    if (Test-Path -LiteralPath $temporaryPath -PathType Leaf) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }

    $invokeWebRequestParameters = @{
        Uri     = $DownloadUrl
        OutFile = $temporaryPath
    }

    if ((Get-Command -Name 'Invoke-WebRequest').Parameters.ContainsKey('UseBasicParsing')) {
        $invokeWebRequestParameters.UseBasicParsing = $true
    }

    $previousProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    try {
        Write-StepResult -Level INFO -Message "Downloading $($Asset.Name) from $DownloadUrl"
        Invoke-WebRequest @invokeWebRequestParameters
        Move-Item -LiteralPath $temporaryPath -Destination $destinationPath -Force
    }
    catch {
        if (Test-Path -LiteralPath $temporaryPath -PathType Leaf) {
            Remove-Item -LiteralPath $temporaryPath -Force
        }

        throw
    }
    finally {
        $ProgressPreference = $previousProgressPreference
    }

    Write-StepResult -Level PASS -Message "Saved $($Asset.Name) to '$destinationPath'."
    return $destinationPath
}

Write-Section "Preparing Day 2 workshop asset download"
$resolvedDestinationDirectory = [System.IO.Path]::GetFullPath($DestinationDirectory)

if (-not (Test-Path -LiteralPath $resolvedDestinationDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $resolvedDestinationDirectory -Force | Out-Null
    Write-StepResult -Level PASS -Message "Created asset directory '$resolvedDestinationDirectory'."
}
else {
    Write-StepResult -Level INFO -Message "Using asset directory '$resolvedDestinationDirectory'."
}

Write-Section "Downloading and validating Day 2 assets"
foreach ($asset in $assetDefinitions) {
    $assetSourcePath = if ($asset.SourcePath) { $asset.SourcePath } else { $sourceAssetPath }
    $downloadUrl = Get-AssetDownloadUrl -Owner $sourceOwner -Repository $sourceRepository -BranchName $Branch -AssetPath $assetSourcePath -FileName $asset.Name
    $assetPath = Save-WorkshopAsset -Asset $asset -TargetDirectory $resolvedDestinationDirectory -DownloadUrl $downloadUrl -Overwrite $Force.IsPresent

    Assert-NonEmptyFile -Path $assetPath -Label $asset.Name | Out-Null
    if ($asset.Type -eq 'Csv') {
        Assert-CsvCanParse -Path $assetPath -Label $asset.Name
    }
}

Write-Section "Day 2 asset bootstrap complete"
Write-StepResult -Level PASS -Message "Day 2 workshop assets are ready in '$resolvedDestinationDirectory'. Core assets (WoodgroveLending solution ZIP and CSVs) match the default paths used by workshop-config.example.json. Sample resumes, assessment template, and Enterprise starter solutions are also available for Labs 16, 19, and 21."
