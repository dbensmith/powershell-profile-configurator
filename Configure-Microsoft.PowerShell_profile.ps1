#Requires -RunAsAdministrator

# Install the Cascadia Code font for use in profile and terminal configuration
# Note that this action forcibly downloads and installs fonts, even if they already exist
# This is also the dependent action for -RunAsAdministrator
& "$PSScriptRoot\Install-CascadiaCode.ps1"
Write-Output ""

# Set variables
$CurrentUserPoshDir = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell"
$CurrentUserWinPoshDir = [Environment]::GetFolderPath("MyDocuments") + "\WindowsPowerShell"
$Profiles = @("$CurrentUserPoshDir\Microsoft.PowerShell_profile.ps1","$CurrentUserWinPoshDir\Microsoft.PowerShell_profile.ps1","$CurrentUserPoshDir\Microsoft.VSCode_profile.ps1")
$SourceProfile = "$PSScriptRoot\Microsoft.PowerShell_profile.ps1"

Write-Output "Configuring PowerShell and Visual Studio Code terminal profiles . . ."
foreach ($ProfilePath in $Profiles) {
    $ProfilePathBak = $ProfilePath
    If (Test-Path $ProfilePath) {
        $i = 0
        While (Test-Path $ProfilePathBak) {
            $i += 1
            $ProfilePathBak = "$ProfilePath.bak$i"
        }
        Write-Output "Backing up old profile . . ."
        Copy-Item -Path $ProfilePath -Destination $ProfilePathBak -Verbose
    } Else {
        Write-Information "$ProfilePath does not exist, so no backup is required."
    }
    Write-Output "Copying new profile . . ."
    Copy-Item -Path $SourceProfile -Destination $ProfilePath -Force -Verbose
    Write-Output ""
}

# Set PSGallery to Trusted
If ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne "Trusted") {
    Write-Output "PSGallery repository is not trusted. Setting PSGallery to Trusted . . ."
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

# Install the modules required to configure PowerShell prompts
$RequiredModules = @("Terminal-Icons","posh-git")

foreach ($Module in $RequiredModules) {
    try {
        Get-InstalledModule $Module -ErrorAction Stop
        Update-Module $Module -Scope CurrentUser -ErrorAction Stop
        Import-Module $Module
    }
    catch {
        Write-Output "Error importing or updating $Module. Installing now."
        Install-Module $Module -Scope CurrentUser -Force -SkipPublisherCheck
        Import-Module $Module
    }
}

# Install oh-my-posh using winget, silently
winget install JanDeDobbeleer.OhMyPosh -h --accept-source-agreements --accept-package-agreements

# Configure Windows Terminal Profile
# This may be harder because it's safer to add/modify settings in the JSON than it is to replace the whole file, due to differing terminal profiles per-system
#$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\Settings.json
#$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\Settings.json

# Automatically opt out of VMware CEIP, if VMware PowerCLI is installed
If (Get-Module VMware.VimAutomation.Core) {
    If ((Get-PowerCLIConfiguration -Scope CurrentUser).ParticipateInCEIP -ne $false) {
        Set-PowerCLIConfiguration -Scope CurrentUser -ParticipateInCEIP $false -Verbose
    }
}