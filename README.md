# powershell-profile-configurator

Configures the user's PowerShell profile for both Windows PowerShell and PowerShell 7+. Personalised for the author's use. Backs up existing profiles by making a copy in the same folder as the original.

## How To Use

1. Edit the list of fonts in `Configure-WindowsFonts-List.csv` to include links to the fonts you want to download and the desired filename of the output (Optional).
    * If you want to install fonts downloaded locally instead, put them in the `src` folder and the script will install them.
2. Edit `Microsoft.PowerShell_profile.ps1` and change `$Theme` to the [Oh My Posh theme](https://ohmyposh.dev/docs/themes) you wish to use.
3. Using an elevated PowerShell prompt, run `Configure-Microsoft.PowerShell_profile.ps1`. The current user's Windows PowerShell, PowerShell 7+, and Visual Studio Code console profiles will be replaced by `Microsoft.PowerShell_profile.ps1`, the specified fonts will be installed, and all necessary module prerequisites will be downloaded and installed.
