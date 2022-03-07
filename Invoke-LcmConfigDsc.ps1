[DSCLocalConfigurationManager()]
configuration LCMConfig
{
	Node localhost
	{
		Settings {
			ConfigurationMode = 'ApplyAndAutoCorrect'
			# Check for updates once a day
			ConfigurationModeFrequencyMins = 1440
		}
	}
}

$LCMFolder = "C:\DSC\Configurations"
if (-not (Get-Item -Path $LCMFolder -ErrorAction SilentlyContinue)) { New-Item -ItemType directory -Path $LCMFolder -Force -Verbose }
# Generate MOF files based on DSC LCM configuration
LCMConfig -OutputPath $LCMFolder
# Apply DSC LCM configuration based on MOF files
Set-DscLocalConfigurationManager -Path $LCMFolder
#if (Get-Item -Path $LCMFolder -ErrorAction SilentlyContinue ) { Remove-Item -Path $LCMFolder -Force -Recurse -Verbose }