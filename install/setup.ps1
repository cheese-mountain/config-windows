& "./php.ps1"
& "./winget.ps1"

Install-Module Terminal-Icons

Remove-Item "C:\Users\kaspe\AppData\Roaming\herdr\config.toml" -Force
New-Item -ItemType SymbolicLink -Path "C:\Users\kaspe\AppData\Roaming\herdr\config.toml" -Value "C:\Users\kaspe\dev\config\herdr.config.toml"

Write-Host "Package installation complete!" -ForegroundColor Cyan

