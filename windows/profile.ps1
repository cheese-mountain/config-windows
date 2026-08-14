# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

# Force Unix/Emacs keybindings for terminal navigation
Set-PSReadLineOption -EditMode Emacs

Set-Alias -Name vim -Value nvim

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
Set-Alias -Name cd -Value z

$omp_config = Join-Path $PSScriptRoot "..\assets\dotfiles\oh-my-posh.json"
oh-my-posh --init --shell pwsh --config $omp_config | Invoke-Expression

Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

# --- repo picker -------------------------------------------------------------
# This was three files - fd.ps1, herdr-fd.ps1 and herdr-layout.ps1 - because the
# picker was also reachable from a herdr popup, and a popup is a separate
# `pwsh -NoProfile` process that can see nothing defined here. It also could not
# Set-Location the pane that opened it, a child cannot change a sibling's cwd, so
# it had to resolve the originating pane from a snapshot and type the cd in with
# send-text. Running the picker in the pane's own shell instead makes all of that
# unnecessary: Set-Location just works, and $env:HERDR_PANE_ID is already the
# pane we are in.

function Select-RepoDir {
    Get-ChildItem -Path "$HOME\repos" -Directory |
        ForEach-Object { $_.FullName } |
        fzf `
            --preview 'lsd --color=always --icon=always {}' `
            --preview-window=right:50% `
            --height=80% `
            --border
}

# Applies the standard herdr working shape to a pane's workspace: the pane's own
# tab becomes "editor" - the editor in the main pane, an agent in a narrow
# full-height sidebar on the right - and companion "agents" and "tools" tabs are
# created alongside it. Focus is left on the editor. herdr has no layout
# templates of its own, so the shape has to be built with explicit API calls.
function Set-HerdrLayout {
    param(
        # Pane to build the layout around. It stays the main pane of the editor tab.
        [Parameter( Mandatory )][string] $PaneId,

        # Directory the new panes and tabs start in. Passed explicitly because
        # herdr learns a pane's cwd from an escape sequence the prompt emits, and
        # the prompt has not been redrawn yet when this runs - as far as herdr is
        # concerned the pane is still in the directory we just left.
        [string] $Cwd,

        # Fraction of the width the main pane keeps; the rest becomes the sidebar.
        [double] $SidebarRatio = 0.7,

        # Started in the main pane and in the sidebar once the split exists.
        # Pass an empty string to leave either pane at a bare shell.
        [string] $EditorCommand = 'nvim',
        [string] $SidebarCommand = 'claude agents'
    )

    # Tabs created next to the editor tab, in order. They are left as plain
    # single-pane tabs: what goes in them gets split by hand as needed, so applying
    # the editor sidebar to them would only be in the way.
    $companionTabs = @('agents', 'tools')

    $snapshot = (herdr api snapshot | ConvertFrom-Json).result.snapshot

    $pane = $snapshot.panes | Where-Object { $_.pane_id -eq $PaneId }
    if (-not $pane) {
        # $env:HERDR_PANE_ID is stamped into the pane when its shell starts and is
        # never updated, so a long-lived shell keeps a dead id once the herdr
        # server has restarted under it. The picker always runs in the focused
        # pane, so that is the reliable answer to "which pane is this".
        $pane = $snapshot.panes | Where-Object { $_.pane_id -eq $snapshot.focused_pane_id }
    }
    if (-not $pane) {
        Write-Host "herdr-layout: unknown pane $PaneId" -ForegroundColor Red
        return
    }

    $PaneId = $pane.pane_id
    $tabId = $pane.tab_id
    $workspaceId = $pane.workspace_id

    # Splitting a tab that is already split would nest the layout instead of
    # replacing it, so leave anything the user has already arranged alone.
    $paneCount = ($snapshot.panes | Where-Object { $_.tab_id -eq $tabId }).Count
    if ($paneCount -gt 1) { return }

    $splitArgs = @()
    if ($Cwd) { $splitArgs = @('--cwd', $Cwd) }

    # Split off the root so the sidebar spans the full height of the tab.
    herdr pane split --pane $PaneId --direction right --ratio $SidebarRatio --no-focus @splitArgs | Out-Null

    # split does not report the pane it created, but the tab was guarded to a
    # single pane above, so the sidebar is the only other pane in it now.
    $sidebar = (herdr api snapshot | ConvertFrom-Json).result.snapshot.panes |
        Where-Object { $_.tab_id -eq $tabId -and $_.pane_id -ne $PaneId } |
        Select-Object -First 1

    # `pane run` submits a command line to the pane's existing shell instead of
    # replacing its process. For the main pane that is this very shell, which is
    # still inside the Ctrl+f handler and not reading input yet - so the editor
    # lands on the prompt as it comes back, rather than being launched from
    # underneath PSReadLine.
    if ($EditorCommand) { herdr pane run $PaneId $EditorCommand | Out-Null }

    if ($sidebar -and $SidebarCommand) {
        herdr pane run $sidebar.pane_id $SidebarCommand | Out-Null
    }

    herdr tab rename $tabId editor | Out-Null

    # An unnamed tab's label is its position ("1", "2"), never a companion name,
    # so matching on label is enough to tell an existing companion tab apart from
    # an untouched one. Without this, rerunning on a tab whose sidebar had been
    # closed would stack up a second set of agents/tools tabs.
    $existingLabels = $snapshot.tabs |
        Where-Object { $_.workspace_id -eq $workspaceId } |
        ForEach-Object { $_.label }

    foreach ($label in $companionTabs) {
        if ($existingLabels -contains $label) { continue }

        # --no-focus keeps the editor tab in front; the companions are set up
        # behind it and switched to with the normal tab keybindings.
        $tabArgs = @('--label', $label, '--no-focus')
        if ($workspaceId) { $tabArgs += @('--workspace', $workspaceId) }
        if ($Cwd) { $tabArgs += @('--cwd', $Cwd) }

        herdr tab create @tabArgs | Out-Null
    }

    # Every split and companion tab above is created with --no-focus, so focus
    # should still be on the main pane. `pane focus` is directional only, with no
    # focus-by-id, so there is nothing to reassert at the pane level - focusing
    # the tab just guarantees the editor is the one in front.
    herdr tab focus $tabId | Out-Null
}

function fd {
    # No Out-String on the fzf output: it appends CRLF, and Set-Location then
    # fails on the trailing newline. fzf's single-line output is already clean.
    $selectedDir = Select-RepoDir
    if (-not $selectedDir) { return }   # user pressed Esc

    Set-Location $selectedDir

    # Inside herdr, jumping to a repo also means building the working shape around
    # it. Outside one, the cd is the whole job.
    if ($env:HERDR_PANE_ID) {
        Set-HerdrLayout -PaneId $env:HERDR_PANE_ID -Cwd $selectedDir
    }
}

# InvokePrompt redraws the prompt in place; without it the shell has already
# changed directory but the visible prompt still shows the old one.
Set-PSReadLineKeyHandler -Key Ctrl+f -ScriptBlock {
    fd
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}
