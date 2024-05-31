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

# Terminal Icons has a font prerequisite.
# You can install any Nerd Font available at https://www.nerdfonts.com.
# As of April 2024, Microsoft now bundles a Nerd Fonts variant of Cascadia Code. Configure fonts in Windows Terminal and VS Code.

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
& ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$Theme.omp.json" --print) -join "`n")) # Avoids misinformed A/V detections
#oh-my-posh init shell pwsh --config $env:POSH_THEMES_PATH\$Theme.omp.json | Invoke-Expression
