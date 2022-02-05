<#
.SYNOPSIS
	Downloads a list of fonts and then install them. Supports OpenText and TrueType fonts.

.DESCRIPTION
	This script will install OTF and TTF fonts that exist in the specified directory.
	
	Use -Path to specify a directory. If no directory is specified, the script will recursively find and install fonts within the script root.
	Use -Download to attempt to read and download a list of font URIs from the file specified by $FontList (Default: Configure-WindowsFonts-List.csv).
	
.NOTES
	Created:	2021-06-24 (Mick Pletcher)
	Modified:	2022-01-01 (Benjamin Smith)
	Filename:	Configure-WindowsFonts.ps1

.LINK
	Original Source: https://github.com/MicksITBlogs/PowerShell/blob/master/InstallFonts.ps1
#>
#Requires -RunAsAdministrator

param (
	[Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$Path = $PSScriptRoot,
	[Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()]$FontList = "$PSScriptRoot\Configure-WindowsFonts-List.csv",
	[Parameter(Mandatory = $false)][Switch]$Download
)

function Invoke-DownloadFont {
	<#
	.SYNOPSIS
	Font Downloader

	.DESCRIPTION
	Downloads font files from the URIs specified in the target CSV.

	.LINK
	Source: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts
	#>

	param (
		[Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][System.IO.FileInfo]$Path = $PSScriptRoot,
		[Parameter(Mandatory = $false)][ValidateNotNullOrEmpty()][Array[]]$Fonts = (Import-Csv $FontList)
	)
	
	If (-not (Test-Path "$Path\src" ) ) {
		New-Item -ItemType Directory -Path "$Path\src" -Force
	}

	foreach ($Font in $Fonts) {
		$DestinationPath = "$Path\src\" + $Font.Destination
		If (Test-Path $DestinationPath) {
			Remove-Item $DestinationPath -Force -ErrorAction SilentlyContinue
		}
		Write-Host ("Downloading" + [char]32 + $Font.Source + [char]32 + ". . . ") -NoNewLine
		# Download the font file
		Start-BitsTransfer -Source $Font.Source -Destination $DestinationPath -DisplayName $Font.Destination -TransferType Download
		# Test to see if the font file was downloaded successfully
		If (Test-Path $DestinationPath) {
			Write-Host ("Success") -ForegroundColor Green
		}
		else {
			Write-Host ("Failed") -ForegroundColor Red
		}
	}
	Write-Output ""
}

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
	
	.NOTES
		Additional information about the function.
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
		Write-Host ("Copying" + [char]32 + $FontFile.Name + [char]32 + "to $env:SystemRoot\Fonts\ . . . ") -NoNewLine
		# If a matching font file already exists in the system fonts folder, delete the target file
		If (Test-Path ("$env:SystemRoot\Fonts\" + $FontFile.Name)) {
			Remove-Item -Path ("$env:SystemRoot\Fonts\" + $FontFile.Name) -Force
		}
		# Copy new font file to system fonts folder
		Copy-Item -Path $FontFile.FullName -Destination ("$env:SystemRoot\Fonts\" + $FontFile.Name) -Force -ErrorAction SilentlyContinue
		# Test if the font was successfully copied over
		If (Test-Path ("$env:SystemRoot\Fonts\" + $FontFile.Name)) {
			Write-Host ("Success") -Foreground Green
		}
		else {
			Write-Host ("Failed") -ForegroundColor Red
		}
		$Copy = $false
		# Test if font registry entry exists
		If (Get-ItemProperty -Name $FontName -Path $FontRegistryPath -ErrorAction SilentlyContinue) {
			# Test if the registry entry matches the font file name
			If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
				Write-Host ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . ") -NoNewline
				Write-Host ("Success") -ForegroundColor Green
			}
			else {
				$AddKey = $true
				Remove-ItemProperty -Name $FontName -Path $FontRegistryPath -Force
				Write-Host ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . ") -NoNewline
				$null = New-ItemProperty -Name $FontName -Path $FontRegistryPath -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue
				If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
					Write-Host ("Success") -ForegroundColor Green
				}
				else {
					Write-Host ("Failed") -ForegroundColor Red
				}
				$AddKey = $false
			}
		}
		else {
			$AddKey = $true
			Write-Host ("Adding" + [char]32 + $FontName + [char]32 + "to the registry . . . ") -NoNewline
			$null = New-ItemProperty -Name $FontName -Path $FontRegistryPath -PropertyType string -Value $FontFile.Name -Force -ErrorAction SilentlyContinue
			If ((Get-ItemPropertyValue -Name $FontName -Path $FontRegistryPath) -eq $FontFile.Name) {
				Write-Host ("Success") -ForegroundColor Green
			}
			else {
				Write-Host ("Failed") -ForegroundColor Red
			}
			$AddKey = $false
		}
		
	}
 catch {
		If ($Copy -eq $true) {
			Write-Host ("Failed") -ForegroundColor Red
			$Copy = $false
		}
		If ($AddKey -eq $true) {
			Write-Host ("Failed") -ForegroundColor Red
			$AddKey = $false
		}
		Write-Warning $_.Exception.Message
	}
	Write-Host
}

# Download fonts
If ($Download.IsPresent) {
	Invoke-DownloadFont
}

# Get a list of all font files relative to this script and parse through the list
foreach ($FontItem in (Get-ChildItem -Path $Path -Recurse | Where-Object { ($_.Name -like "*.ttf") -or ($_.Name -like "*.otf") } ) ) {
	Install-Font -FontFile $FontItem
}
