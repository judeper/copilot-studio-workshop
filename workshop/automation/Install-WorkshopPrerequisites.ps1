[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [switch]$SkipPnPInstall
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

. (Join-Path -Path $PSScriptRoot -ChildPath 'Common.ps1')

Write-Section "Checking local workshop prerequisites"

if (Get-Module -ListAvailable -Name 'PnP.PowerShell') {
    Write-StepResult -Level PASS -Message "PnP.PowerShell is already installed."
}
elseif ($SkipPnPInstall) {
    throw "PnP.PowerShell is not installed. Re-run without -SkipPnPInstall to install it for the current user."
}
else {
    $performedInstall = $false
    if ($PSCmdlet.ShouldProcess('PnP.PowerShell', 'Install for the current user')) {
        Install-Module -Name 'PnP.PowerShell' -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        $performedInstall = $true
    }

    if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
        if ($performedInstall) {
            throw "PnP.PowerShell installation did not complete successfully."
        }

        Write-StepResult -Level WARN -Message "PnP.PowerShell is still not installed. Approve the install and run this script again."
        return
    }

    Write-StepResult -Level PASS -Message "Installed PnP.PowerShell for the current user."
}

if (Get-Command -Name 'pac' -ErrorAction SilentlyContinue) {
    Write-StepResult -Level PASS -Message "Power Platform CLI (pac) is available."
}
else {
    Write-StepResult -Level WARN -Message "Power Platform CLI (pac) is not installed. Install it before you try to bootstrap a workshop environment or import the WoodgroveLending solution."
}
