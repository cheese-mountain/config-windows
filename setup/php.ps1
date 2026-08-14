function No-Command-For($name) {
    return -Not (Get-Command $name -ErrorAction SilentlyContinue)
}

# Install Composer packages if it is installed
if (Get-Command "composer" -ErrorAction SilentlyContinue) {
    Write-Host "Installing Composer global packages..." -ForegroundColor Yellow
    composer global require --quiet php-stubs/wordpress-globals php-stubs/wordpress-stubs php-stubs/woocommerce-stubs php-stubs/acf-pro-stubs wpsyntex/polylang-stubs php-stubs/genesis-stubs php-stubs/wp-cli-stubs
}

$phpDir = "C:\php"

if (No-Command-For "php") {
    Write-Host "PHP not found. Installing..." -ForegroundColor Yellow

    $phpUrl = "https://windows.php.net/downloads/releases/php-8.3.2-Win32-vs16-x64.zip"

    if (-Not (Test-Path $phpDir)) {
        New-Item -ItemType Directory -Path $phpDir | Out-Null
    }

    $phpZip = "$env:TEMP\php.zip"
    Invoke-WebRequest $phpUrl -OutFile $phpZip
    Expand-Archive $phpZip -DestinationPath $phpDir -Force
    Remove-Item $phpZip

    if (-Not (Test-Path "$phpDir\php.ini")) {
        Copy-Item "$phpDir\php.ini-development" "$phpDir\php.ini"
    }

    # Enable common WP extensions
    $phpIni = "$phpDir\php.ini"
    (Get-Content $phpIni) `
        -replace ';extension=mysqli', 'extension=mysqli' `
        -replace ';extension=curl', 'extension=curl' `
        -replace ';extension=mbstring', 'extension=mbstring' `
        -replace ';extension=openssl', 'extension=openssl' `
        | Set-Content $phpIni

    # Add to PATH if missing
    $machinePath = [Environment]::GetEnvironmentVariable("Path","Machine")
    if ($machinePath -notlike "*$phpDir*") {
        [Environment]::SetEnvironmentVariable(
            "Path",
            $machinePath + ";$phpDir",
            "Machine"
        )
    }

    Write-Host "PHP installed successfully." -ForegroundColor Green
}

$wpCliDir = "C:\wp-cli"

if (No-Command-For "wp") {
    Write-Host "`nWP-CLI not found. Installing..." -ForegroundColor Yellow

    if (-Not (Test-Path $wpCliDir)) {
        New-Item -ItemType Directory -Path $wpCliDir | Out-Null
    }

    $wpPhar = "$wpCliDir\wp.phar"
    $wpBat  = "$wpCliDir\wp.bat"

    Invoke-WebRequest `
      https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar `
      -OutFile $wpPhar

    @"
@echo off
php "%~dp0wp.phar" %*
"@ | Set-Content $wpBat -Encoding ASCII

    # Add to PATH if missing
    $machinePath = [Environment]::GetEnvironmentVariable("Path","Machine")

    if ($machinePath -notlike "*$wpCliDir*") {
        [Environment]::SetEnvironmentVariable(
            "Path",
            $machinePath + ";$wpCliDir",
            "Machine"
        )
    }

    Write-Host "WP-CLI installed successfully." -ForegroundColor Green
}
