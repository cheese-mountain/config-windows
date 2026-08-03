$repo = Split-Path $PSScriptRoot -Parent

# source (relative to repo root) -> target
$links = [ordered]@{
    "herdr.config.toml"      = "$env:APPDATA\herdr\config.toml"
    ".tmux.conf"             = "$HOME\.tmux.conf"
    "CLAUDE.md"             = "$HOME\.claude\CLAUDE.md"
    "nvim"                   = "$env:LOCALAPPDATA\nvim"
    "windows\.gitconfig"     = "$HOME\.gitconfig"
    "windows\terminal.json"  = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    "vscode\settings.jsonc"  = "$env:APPDATA\Code\User\settings.json"
    "vscode\keybindings.jsonc" = "$env:APPDATA\Code\User\keybindings.json"
    "vscode\tasks.jsonc"     = "$env:APPDATA\Code\User\tasks.json"
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal $identity).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-Not (Test-Admin)) {
    Write-Host "Not running as admin - symlink creation needs admin or Developer Mode enabled." -ForegroundColor Yellow
}

Write-Host "`nLinking config files..." -ForegroundColor Cyan

foreach ($entry in $links.GetEnumerator()) {
    $source = Join-Path $repo $entry.Key
    $target = $entry.Value

    if (-Not (Test-Path $source)) {
        Write-Host "  skip  $($entry.Key) (missing in repo)" -ForegroundColor DarkGray
        continue
    }

    $parent = Split-Path $target -Parent
    if (-Not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $existing = Get-Item $target -Force -ErrorAction SilentlyContinue
    if ($existing) {
        if ($existing.LinkType -eq "SymbolicLink") {
            if ($existing.Target -eq $source) {
                Write-Host "  ok    $target" -ForegroundColor DarkGray
                continue
            }
            $existing.Delete()
        }
        else {
            $backup = "$target.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item $target $backup
            Write-Host "  moved existing $target -> $backup" -ForegroundColor Yellow
        }
    }

    try {
        New-Item -ItemType SymbolicLink -Path $target -Target $source -ErrorAction Stop | Out-Null
        Write-Host "  link  $target -> $source" -ForegroundColor Green
    }
    catch {
        Write-Host "  fail  $target ($($_.Exception.Message))" -ForegroundColor Red
    }
}

# The PowerShell profile is dot-sourced instead of symlinked so that $PSScriptRoot
# inside profile.ps1 still resolves to the repo (oh-my-posh.json sits next to it).
$profileSource = Join-Path $repo "windows\profile.ps1"
$line = ". `"$profileSource`""

# Target pwsh 7's AllHosts profile explicitly: $PROFILE resolves to whichever edition
# runs this script, and running it from Windows PowerShell would write to
# Documents\WindowsPowerShell instead - where the profile can't work anyway.
$profilePath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\profile.ps1"
$parent = Split-Path $profilePath -Parent
if (-Not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

if ((Test-Path $profilePath) -and (Select-String -Path $profilePath -SimpleMatch $profileSource -Quiet)) {
    Write-Host "  ok    $profilePath" -ForegroundColor DarkGray
}
else {
    Add-Content -Path $profilePath -Value $line
    Write-Host "  added profile source to $profilePath" -ForegroundColor Green
}
