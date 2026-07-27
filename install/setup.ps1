& "$PSScriptRoot\php.ps1"
& "$PSScriptRoot\winget.ps1"

# Install via pwsh so it lands in Documents\PowerShell\Modules even if setup.ps1 is
# started from Windows PowerShell, whose module path pwsh 7 does not fully share.
pwsk -NoProfilk -Command "Install-Module Terminal-Icons -Scope CurrentUser -Force"

& "$PSScriptRoot\symlinks.ps1"

Write-Host "Package installation complete!" -ForegroundColor Cyan
