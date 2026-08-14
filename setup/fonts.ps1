$repo = Split-Path $PSScriptRoot -Parent
$fontDir = Join-Path $repo "assets\fonts"

# Shell "Fonts" special folder (0x14). CopyHere copies the file into
# C:\Windows\Fonts AND writes the registry registration in one step - doing that
# by hand needs the correct face name per file, which the shell resolves for us.
# Flag 0x10 = "yes to all", suppressing the replace-confirmation dialog.
$shellFonts = (New-Object -ComObject Shell.Application).Namespace(0x14)

# A font counts as installed if its file exists machine-wide (C:\Windows\Fonts,
# elevated install) OR per-user (%LOCALAPPDATA%\Microsoft\Windows\Fonts, which is
# where the shell puts it when setup is not run as admin).
$installedDirs = @(
    (Join-Path $env:WINDIR "Fonts"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts")
)

Write-Host "`nInstalling fonts..." -ForegroundColor Cyan

Get-ChildItem -Path $fontDir -Recurse -Include *.ttf, *.otf | ForEach-Object {
    $name = $_.Name
    $alreadyInstalled = $installedDirs | Where-Object { Test-Path (Join-Path $_ $name) }
    if ($alreadyInstalled) {
        Write-Host "  ok    $name" -ForegroundColor DarkGray
    }
    else {
        $shellFonts.CopyHere($_.FullName, 0x10)
        Write-Host "  add   $name" -ForegroundColor Green
    }
}
