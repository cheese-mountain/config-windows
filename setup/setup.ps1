& "$PSScriptRoot\winget.ps1"

pwsh -NoProfile -Command "Install-Module Terminal-Icons -Scope CurrentUser -Force"

& "$PSScriptRoot\symlinks.ps1"
& "$PSScriptRoot\startup.ps1"
& "$PSScriptRoot\ssh.ps1"

# powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"
# npm i -g hunkdiff
# & "$PSScriptRoot\php.ps1"

Write-Host "Package installation complete!" -ForegroundColor Cyan
