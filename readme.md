# Getting started

```powershell
# Install Git and GitHub CLI
winget install --id Git.Git -e --source winget
winget install --id GitHub.cli -e --source winget

# Refresh environment variables so 'gh' and 'git' commands are instantly recognized 
# (Avoids needing to restart PowerShell mid-script)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Authenticate with GitHub (Requires manual interactive setup in terminal)
gh auth login

# Navigate to ~/repos (creates directory if missing)
New-Item -ItemType Directory -Path "$HOME\repos" -Force | Set-Location

# Clone repo and enter folder
gh repo clone cheese-mountain/config
Set-Location config

# Run setup script
powershell.exe -ExecutionPolicy Bypass -File ./setup.ps1
```
