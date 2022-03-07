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

# Terminal Icons has a font prerequisite.
# Install any Nerd Font available at https://www.nerdfonts.com.
# Currently using Cousine NF for PowerShell and UbuntuMono NF for Pengwin. Configure in Windows Terminal and VS Code.

# Powerline for Windows PowerShell has font and module prerequisites.
# https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup
# Nerd Fonts fully support Powerline.

$RequiredModules = @("Terminal-Icons","posh-git")
$Theme = "slimfat"

foreach ($Module in $RequiredModules) {
    try {
        Import-Module $Module -ErrorAction Stop
    }
    catch {
        Write-Warning "Couldn't import $Module. Installing now."
        Install-Module $Module -Scope CurrentUser -Force
        Import-Module $Module
    }
}

# Set oh-my-posh theme and enable use of posh-git
$env:POSH_GIT_ENABLED = $true
oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH\$Theme.omp.json | Invoke-Expression