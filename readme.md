# Getting started

```powershell
# Install Git and GitHub CLI
winget install -e --id Google.Chrome
winget install -e --id Git.Git
winget install -e --id Github.cli

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Authenticate with GitHub (Requires manual interactive setup in terminal)
gh auth login

# Navigate to ~/repos (creates directory if missing)
New-Item -ItemType Directory -Path "$HOME\repos" -Force | Set-Location

# Clone repo and enter folder
gh repo clone kasper-ostberg/config
Set-Location config/setup

# Run setup script
powershell.exe -ExecutionPolicy Bypass -File ./setup.ps1
```
