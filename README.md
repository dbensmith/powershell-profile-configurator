# powershell-profile-configurator

Configures the user's PowerShell profile for Windows PowerShell (5.1), PowerShell Core (7+), and the integrated terminal for Visual Studio Code. Backs up existing profiles by making a copy in the same folder as the original. Personalised for the author's use; fork and customize to your heart's content!

## What the configurator does

- Downloads and installs the latest version of the Cascadia Code font in `Install-CascadiaCode.ps1`
- Copies `Microsoft.PowerShell_profile.ps1` to the current user's profile directory for each of the following consoles:
  - Windows PowerShell (5.1)
  - PowerShell Core (7+)
  - Visual Studio Code (renamed to `Microsoft.VSCode_profile.ps1`)
- For the PowerShell console the configurator script was run from:
  - Sets the PSGallery repository to Trusted
  - Installs the PowerShell modules [Oh My Posh](https://ohmyposh.dev), [Terminal Icons](https://github.com/devblackops/Terminal-Icons), and [posh-git](https://github.com/dahlbyk/posh-git)
  - Opts out of the VMWare CEIP, if the PowerCLI module is installed, so it doesn't prompt you for telemetry the first time you use it

## What the included profile does

- Imports the prerequisite modules described in the configurator, and if they are not present, installs them.
- Configures the PowerShell terminal prompt with the Oh My Posh theme specified in the script (default: [slimfat](https://ohmyposh.dev/docs/themes#slimfat)).
- Enables the TLS 1.2/1.3 security protocols for the PowerShell session.

## How to use this

1. Edit `Microsoft.PowerShell_profile.ps1` and change `$Theme` to the [Oh My Posh theme](https://ohmyposh.dev/docs/themes) you wish to use.
2. Using an elevated PowerShell prompt, run `Configure-Microsoft.PowerShell_profile.ps1`. Note that some of the configurator script's changes are only applied to the terminal it was run from.
