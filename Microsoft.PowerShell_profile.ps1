# Resolve issues with Oh My Posh after the release of PowerShell 7.4
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# Enable TLS 1.2 and TLS 1.3 security protocols
try {
    $SecurityProtocols = [Net.ServicePointManager]::SecurityProtocol
    if ($SecurityProtocols -notlike '*Tls12*') {
        Write-Information "Enabling TLS 1.2 for service points in this session."
        [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls12
    }
    if ($SecurityProtocols -notlike '*Tls13*') {
        Write-Information "Enabling TLS 1.3 for service points in this session."
        [Net.ServicePointManager]::SecurityProtocol += [Net.SecurityProtocolType]::Tls13
    }
}
catch {
    Write-Warning "Unable to configure service points with modern TLS protocols."
}
Write-Information ("Service point security protocols in this session: " + [Net.ServicePointManager]::SecurityProtocol)

# Terminal Icons has a Nerd Font prerequisite Install any Nerd Font from https://www.nerdfonts.com.
# As of April 2024, Microsoft now offers an official Nerd Font variant of Cascadia Code.
# Make sure to configure your new fonts in Windows Terminal and VS Code.

$RequiredModules = @("Terminal-Icons","posh-git")

foreach ($Module in $RequiredModules) {
    try {
        Import-Module $Module -ErrorAction Stop
    }
    catch {
        Write-Warning "Couldn't import $Module. Installing now."
        if ($Module = "Terminal-Icons") {
            # https://github.com/devblackops/Terminal-Icons/issues/99#issuecomment-1478390425
            Remove-Item -Path "$env:USERPROFILE\AppData\Roaming\powershell\Community\Terminal-Icons" -Recurse -Force -Verbose
        }
        Install-Module $Module -Scope CurrentUser -Force
        Import-Module $Module
    }
}

# Set oh-my-posh theme and enable use of posh-git
$Theme = "slimfat"
$env:POSH_GIT_ENABLED = $true
& ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$Theme.omp.json" --print) -join "`n")) # Avoids false positives by A/V and EDR tools

# Enable DSCv3 completion. Requires DSCv3 to be installed and completion script created via DSCv3.
. ~/dsc_completion.ps1
