# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Aliases
Set-Alias -Name vim -Value nvim

Set-Alias -Name code -Value cursor

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
Set-Alias -Name cd -Value z

# if ($host.Name -eq 'ConsoleHost') {
#     Import-Module PSReadLine
# }

$omp_config = Join-Path $PSScriptRoot ".\oh-my-posh.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSEverything

# Use window style commands (ctrl + c/v/a/x)
Set-PSReadLineOption -EditMode Windows

# Search r (repo), d (directory), f (file) or t (text)
function search($target, $all = $false) {
    $preview = @("--preview", "ls {}")
    $base_options = @("--height", "95%", "--layout", "reverse")
    $options = @("--border")
    $wd = Get-Location
    $at_root = $wd.Path -match '^[A-Za-z]:\\?$'

    switch ($target) {
        "r" {
            $filter = @(".wp-cli", "scoop", "OtherParameters", "AppData")
            $repos = Search-Everything -regularexpression ^.git$
            $items = foreach ($path in $repos) {
                $skip = $false
                foreach ($word in $filter) {
                    if ($path -like "*$word*") {
                        $skip = $true
                        break
                    }
                }
                
                if (-not $skip) {
                    Split-Path -Path $path -Parent
                }
            }
        }
        "d" {
            if ($all) {
                $items = Search-Everything -Filter "folder:"
            } elseif ($at_root) {
                $drives = Get-PSDrive -PSProvider FileSystem
                $items = @()
                foreach ($drive in $drives) {
                    try {
                        Set-Location "$($drive.Name):\"
                        $items += Search-Everything -Filter "folder:" -PathExclude `
                            .pnpm-store, node_modules, .git, .pnpm, RECYCLE.BIN
                    } catch { 
                        continue
                    }
                }
                Set-Location $wd
            } else {
                $items = Search-Everything -Filter "folder:" -PathExclude `
                    .pnpm-store, node_modules, .git, .pnpm, RECYCLE.BIN
            }
        }
        "f" {
            $preview = @("--preview", "bat --color=always --style=numbers --line-range=:500 {}")
            if ($all) {
                $items = Search-Everything -Filter "file:"
            } elseif ($at_root) {
                $drives = Get-PSDrive -PSProvider FileSystem
                $items = @()
                foreach ($drive in $drives) {
                    try {
                        Set-Location "$($drive.Name):\"
                        $items += Search-Everything -Filter "file:" -PathExclude `
                            .pnpm-store, node_modules, .git, .pnpm, RECYCLE.BIN
                    } catch { 
                        continue
                    }
                }
                Set-Location $wd
            } else {
                $items = Search-Everything -Filter "file:" -PathExclude `
                    .pnpm-store, node_modules, .git, .pnpm, RECYCLE.BIN
            }
        }
        "t" {
            if ($all) {
                $rg = "rg --column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --unrestricted"
            } else {
                $rg = "rg --column --line-number --no-heading --color=always --smart-case"
            }
            $reload = "reload: $rg {q} || cd ."
            $preview = @("--preview", "bat --color=always --style=numbers --highlight-line {2} {1}")
            $options = @(
                "--ansi", "--disabled", "--delimiter", ":",
                "--bind", "start:$reload", "--bind", "change:$reload", 
                 "--preview-window", "up,60%,border-bottom"
            )
            $items = "$rg """""
        }
    }

    $fzf = $base_options + $options + $preview
    return $items | fzf @fzf 
}

function fd {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("r", "f", "d", "t")]
        [string]$type = "d",
        [switch]$All
    )

    Clear-Host
     
    $path = search $type $All

    if (!$path) { return }
    if ($type -in @("f", "t")) {
        Set-Location (Split-Path -Path $path -Parent)
    } else {
        Set-Location $path
    }
}

function vsc {
    param(
        [Parameter(Position = 0)]
        [ValidateSet("r", "f", "d", "t", ".")]
        [string]$type = "r"
    )

    Clear-Host
     
    if ($type -eq ".") {
        return code .
    }

    $path = search($type)

    if ($path) {
        code $path
    }
}

# Utilities
function path ($command) {
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function bin($empty) {
    if ($empty -eq "empty") {
        Clear-RecycleBin -Force
    } else {
        explorer.exe shell:RecycleBinFolder
    }
}
