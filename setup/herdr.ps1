# Install it  (check if installed first)
powershell -ExecutionPolicy Bypass -c "irm https://herdr.dev/install.ps1 | iex"

# Plugins
$plugins = @(
    "Kitware.CMake",
);

Write-Host "Checking and installing packages..." -ForegroundColor Cyan
foreach ($package in $packages) {
    Write-Host "`n=== Processing $package ===" -ForegroundColor Cyan

    # Cheap local check first - `winget list` hits only the installed-package
    # registry (no download/hash), so we skip before winget tries to upgrade.
    winget list --id $package --exact --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  already installed, skipping" -ForegroundColor DarkGray
        continue
    }

    winget install --id $package --exact --source winget --accept-package-agreements --accept-source-agreements
}
