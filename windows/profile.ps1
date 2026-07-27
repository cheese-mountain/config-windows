# pwsh 7 only - Windows PowerShell 5.1 ships PSReadLine 2.0.0 (too old for oh-my-posh's
# init script) and uses a different module path, so bail out instead of erroring.
if ($PSVersionTable.PSEdition -ne 'Core') { return }

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

Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

function ln {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target,

        [Parameter(Mandatory=$true)]
        [string]$path
    )
    New-Item -ItemType SymbolicLink -Path $path -Target $target
}
