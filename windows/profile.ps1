# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Set-Alias -Name vim -Value nvim

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
Set-Alias -Name cd -Value z

$omp_config = Join-Path $PSScriptRoot ".\oh-my-posh.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons

function wp-site {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    # Base path
    $basePath = "$HOME\wp-sites"
    $sitePath = Join-Path $basePath $Name

    # Check if site already exists
    if (Test-Path $sitePath) {
        Write-Host "Site '$Name' already exists at $sitePath. Exiting."
        return
    }

    # Create site directory
    New-Item -ItemType Directory -Path $sitePath | Out-Null
    Set-Location $sitePath

    wp core download
    wp config create --dbname="${Name}_wp" --dbuser=root --dbpass= --dbhost="127.0.0.1:3307"
    wp db create
    wp core install --url="${Name}.test" --title="$Name" --admin_user=admin --admin_password=admin --admin_email="admin@${Name}.test" --skip-email

    Write-Host "WordPress site '$Name' created successfully at $sitePath."
}

function ln {
    param(
        [Parameter(Mandatory=$true)]
        [string]$path,

        [Parameter(Mandatory=$true)]
        [string]$target
    )
    New-Item -ItemType SymbolicLink -Path $path -Target $target
}
