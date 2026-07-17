# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Force Unix/Emacs keybindings for terminal navigation
Set-PSReadLineOption -EditMode Emacs

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
        [string]$target,

        [Parameter(Mandatory=$true)]
        [string]$path
    )
    New-Item -ItemType SymbolicLink -Path $path -Target $target
}

function fd {
    $basePath = "C:\Users\kaspe\dev"
    $selectedDir = Get-ChildItem -Path $basePath -Directory |
        ForEach-Object { $_.FullName } |
        fzf `
            --preview 'lsd --color=always --icon=always {}' `
            --preview-window=right:50% `
            --height=80% `
            --border |
        Out-String

    if ($selectedDir) {
        Set-Location $selectedDir
    #     $sessionName = Split-Path $selectedDir -Leaf
    #
    #     # Check if tmux session exists
    #     tmux has-session -t $sessionName 2>$null
    #
    #     if ($LASTEXITCODE -eq 0) {
    #         Write-Host "Session exists, attaching..."
    #         tmux attach-session -t $sessionName
    #     } else {
    #         Write-Host "Session does not exist"
    #         Set-Location $selectedDir
    #         tmux new-session -s $sessionName -c $selectedDir
    #         # tmux attach-session -t $sessionName
    #     }
    }
}

function fd2 {
    Start-Process wsl -ArgumentList "--exec fd" -NoNewWindow -Wait
}

# Bind Ctrl+F to run fd
Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock { fd }
