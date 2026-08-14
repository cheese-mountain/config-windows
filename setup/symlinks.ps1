$repo = Split-Path $PSScriptRoot -Parent

# source (relative to repo root) -> target
$links = [ordered]@{
    "assets\dotfiles\herdr.toml"    = "$env:APPDATA\herdr\config.toml"
    "assets\dotfiles\tmux.conf"     = "$HOME\.tmux.conf"
    "assets\dotfiles\CLAUDE.md"     = "$HOME\.claude\CLAUDE.md"
    "assets\dotfiles\gitconfig"     = "$HOME\.gitconfig"
    "assets\dotfiles\terminal.json" = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    "nvim"                          = "$env:LOCALAPPDATA\nvim"
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
# inside profile.ps1 still resolves to the repo - it walks up from there to reach
# assets\dotfiles\oh-my-posh.json.
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

# Drop any dot-source line left over from a previous repo location before adding
# the current one - otherwise moving the repo leaves a line pointing at nothing.
# Quotes and slash direction vary because older setups wrote the line by hand.
$stale = '^\s*\.\s+"?.*[\\/]profile\.ps1"?\s*$'

$current = if (Test-Path $profilePath) { @(Get-Content $profilePath) } else { @() }
$desired = @($current | Where-Object { $_ -notmatch $stale }) + $line

if (($current -join "`n") -eq ($desired -join "`n")) {
    Write-Host "  ok    $profilePath" -ForegroundColor DarkGray
}
else {
    Set-Content -Path $profilePath -Value $desired
    Write-Host "  sourced profile in $profilePath" -ForegroundColor Green
}

# Sweep the host-specific profile too: it loads alongside the AllHosts one, so a
# stale line there still errors on every shell start.
$hostProfile = Join-Path $parent "Microsoft.PowerShell_profile.ps1"
if (Test-Path $hostProfile) {
    $hostLines = @(Get-Content $hostProfile)
    $hostKept = @($hostLines | Where-Object { $_ -notmatch $stale })
    if ($hostKept.Count -ne $hostLines.Count) {
        Set-Content -Path $hostProfile -Value $hostKept
        Write-Host "  cleaned stale source from $hostProfile" -ForegroundColor Yellow
    }
}
