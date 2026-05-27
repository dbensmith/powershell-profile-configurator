# powershell-profile-configurator [DEPRECATED]

> [!WARNING]
> **This repository is deprecated and no longer maintained.**
> The configuration, scripts, and profile setup have been fully migrated to [chezmoi](https://www.chezmoi.io/) and integrated into the primary dotfiles repository.

---

## Why this repository was deprecated

All features previously managed by standalone scripts in this repository have been migrated to the chezmoi dotfiles management workflow to streamline system initialization, reduce code duplication, and avoid privilege escalation.

### Deprecated Features & Alternatives

| Deprecated Feature | Reason for Deprecation | Modern Replacement in Chezmoi |
| :--- | :--- | :--- |
| **`Install-CascadiaCode.ps1`** | Custom PowerShell font installer required Administrator elevation (UAC), manual GitHub API lookups, zip extractions, and writing to the system fonts registry hive. | **`oh-my-posh font install`**: Used dynamically within chezmoi's `run_once_` phase to download and register fonts (like `CaskaydiaCove`, `Cousine`, and `UbuntuMono`) at the user level without requiring admin privileges. |
| **`Configure-Microsoft.PowerShell_profile.ps1`** | A custom script was required to handle path matching, file copying, and backups across different PowerShell hosts. It struggled to handle dynamic locations (e.g., OneDrive folder redirections) cleanly. | **Chezmoi Lifecycles**: Profile files are managed via a `.chezmoitemplates` template. A Windows-only `run_onchange_` script dynamically queries the active `MyDocuments` path (`[Environment]::GetFolderPath('MyDocuments')`) at runtime to safely deploy files to PowerShell, WindowsPowerShell, and VS Code. |
| **Module Pre-installation** | Redundant step in the configurator script. | Moved to the `run_once_` bootstrap script inside the dotfiles repository. The profile itself remains self-healing and will download/import missing modules automatically on session start. |

---

## Active Configuration Workflow

For active development and profile modification:

1. **Edit the profile template**:
   ```powershell
   chezmoi edit --template ~/.chezmoitemplates/Microsoft.PowerShell_profile.ps1
   ```
2. **Apply changes**:
   ```powershell
   chezmoi apply
   ```
   This will automatically trigger the `run_onchange_install-powershell-profile.ps1` script to update the active profiles across all PowerShell hosts.
