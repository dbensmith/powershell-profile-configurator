<#
.SYNOPSIS
    Downloads and installs the latest version of the Cascadia Code font from Microsoft on GitHub.

.DESCRIPTION
    This script downloads the latest version of Cascadia Code font from GitHub, extracts the 'ttf' folder,
    removes the 'ttf\static' subfolder, installs the remaining .ttf files, and cleans up all temporary files.

.EXAMPLE
    PS C:\> .\InstallCascadiaCode.ps1

.NOTES
    Must be run as Administrator.
#>
#requires -RunAsAdministrator

function Install-Font {
	<#
	.SYNOPSIS
		Install a font

	.DESCRIPTION
		This function will attempt to install the font by copying it to the $env:SystemRoot\fonts directory and then registering it in the registry. This also outputs the status of each step for easy tracking.

	.PARAMETER FontFile
		Name of the Font File to install

	.EXAMPLE
				PS C:\> Install-Font -FontFile $value1
    #>

	param
	(
		[Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$FontFile
	)

	$FontRegistryPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

	# Get Font Name from the File's Extended Attributes
	$ObjShell = New-Object -com shell.application
	$Folder = $ObjShell.namespace($FontFile.DirectoryName)
	$Item = $Folder.Items().Item($FontFile.Name)
	$FontName = $Folder.GetDetailsOf($Item, 21)
	try {
		switch ($FontFile.Extension) {
			".ttf" { $FontName = $FontName + [char]32 + "(TrueType)" }
			".otf" { $FontName = $FontName + [char]32 + "(OpenType)" }
		}
		$Copy = $true
		Write-Information -MessageData ("Copying" + [char]32 + $FontFile.Name + [char]32 + "to $env:SystemRoot\Fonts\ . . . ") -InformationAction Continue
		# If a matching font file already exists in the system fonts folder, delete the target file
		If (Test-Path ("$env:SystemRoot\Fonts\" + $FontFile.Name)) {
			Remove-Item -Path ("$env:SystemRoot\Fonts\" + $FontFile.Name) -Force
		}
		# Copy new font file to system fonts folder
		Copy-Item -Path $FontFile.FullName -Destination ("$env:SystemRoot\Fonts\" + $FontFile.Name) -Force -ErrorAction SilentlyContinue
		# Test if the font was successfully copied over
		If (Test-Path ("$env:SystemRoot\Fonts\" + $FontFile.Name)) {
			Write-Information -MessageData "Success" -InformationAction Continue
		}
		else {
			Write-Error -Message "Failed to copy font file" -ErrorAction Continue
		}
		$Copy = $false
		# Test if font registry entry exists
		If (Get-ItemProperty -Name $FontName -Path $FontRegistryPath -ErrorAction SilentlyContinue) {
			# Test if the registry entry matches the font file name
			If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
				Write-Information -MessageData ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . Success") -InformationAction Continue
			}
			else {
				$AddKey = $true
				Remove-ItemProperty -Name $FontName -Path $FontRegistryPath -Force
				Write-Information -MessageData ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . ") -InformationAction Continue
				$null = New-ItemProperty -Name $FontName -Path $FontRegistryPath -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue
				If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
					Write-Information -MessageData "Success" -InformationAction Continue
				}
				else {
					Write-Error -Message "Failed to register font in registry" -ErrorAction Continue
				}
				$AddKey = $false
			}
		}
		else {
			$AddKey = $true
			Write-Information -MessageData ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . ") -InformationAction Continue
			$null = New-ItemProperty -Name $FontName -Path $FontRegistryPath -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue
			If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
				Write-Information -MessageData "Success" -InformationAction Continue
			}
			else {
				Write-Error -Message "Failed to register font in registry" -ErrorAction Continue
			}
			$AddKey = $false
		}

	}
 catch {
		If ($Copy -eq $true) {
			Write-Error -Message "Failed to copy font file" -ErrorAction Continue
			$Copy = $false
		}
		If ($AddKey -eq $true) {
			Write-Error -Message "Failed to register font in registry" -ErrorAction Continue
			$AddKey = $false
		}
		Write-Warning $_.Exception.Message
	}
}

# Define the repository details
$UserRepo = "microsoft/cascadia-code"
$ApiUrl = "https://api.github.com/repos/$UserRepo/releases/latest"

# Find the latest release
$LatestRelease = Invoke-RestMethod -Uri $ApiUrl

# Find the zip asset and download it
$ZipAsset = $LatestRelease.assets | Where-Object { $_.name -match "CascadiaCode-.*\.zip" }
$ZipUrl = $ZipAsset.browser_download_url
$ZipFile = "$PWD\" + $ZipAsset.name
Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipFile

# Extract the ttf folder
$ExtractPath = "$PWD\CascadiaCode"
Expand-Archive -LiteralPath $ZipFile -DestinationPath $ExtractPath

# Remove the static subfolder
$StaticFolder = "$ExtractPath\ttf\static"
if (Test-Path $StaticFolder) {
    Remove-Item -Recurse -Force $StaticFolder
}

# Install each ttf file in the ttf folder using provided function
$TtfFiles = Get-ChildItem -Path "$ExtractPath\ttf" -Filter *.ttf
foreach ($TtfFile in $TtfFiles) {
    Install-Font -FontFile $TtfFile
}

# Clean up extracted files and downloaded zip file
Remove-Item -Recurse -Force $ExtractPath
Remove-Item -LiteralPath $ZipFile
