$repo = Split-Path $PSScriptRoot -Parent
$fontDir = Join-Path $repo "fonts"

# Shell "Fonts" special folder (0x14). CopyHere copies the file into
# C:\Windows\Fonts AND writes the registry registration in one step - doing that
# by hand needs the correct face name per file, which the shell resolves for us.
# Flag 0x10 = "yes to all", suppressing the replace-confirmation dialog.
$shellFonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
$installedDir = Join-Path $env:WINDIR "Fonts"

Write-Host "`nInstalling fonts..." -ForegroundColor Cyan

Get-ChildItem -Path $fontDir -Recurse -Include *.ttf, *.otf | ForEach-Object {
    $dest = Join-Path $installedDir $_.Name
    if (Test-Path $dest) {
        Write-Host "  ok    $($_.Name)" -ForegroundColor DarkGray
    }
    else {
        $shellFonts.CopyHere($_.FullName, 0x10)
        Write-Host "  add   $($_.Name)" -ForegroundColor Green
    }
}
