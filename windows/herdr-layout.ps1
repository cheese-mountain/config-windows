# Applies the standard herdr working shape to a pane's workspace: the pane's own
# tab becomes "editor" - the pane keeps most of the space with a narrow
# full-height sidebar on the right - and companion "agents" and "tools" tabs are
# created alongside it. Dot-sourced by herdr-fd.ps1; herdr has no layout
# templates of its own, so the shape has to be built with explicit API calls.

# Tabs created next to the editor tab, in order. They are left as plain
# single-pane tabs: what goes in them gets split by hand as needed, so applying
# the editor sidebar to them would only be in the way.
$script:HerdrCompanionTabs = @('agents', 'tools')

function Set-HerdrLayout {
    param(
        # Pane to build the layout around. It stays the main pane of the editor tab.
        [Parameter( Mandatory )][string] $PaneId,

        # Directory the new panes and tabs start in. Passed explicitly because the
        # main pane may not have finished its own cd yet when this runs.
        [string] $Cwd,

        # Fraction of the width the main pane keeps; the rest becomes the sidebar.
        [double] $SidebarRatio = 0.7
    )

    $snapshot = (herdr api snapshot | ConvertFrom-Json).result.snapshot

    $pane = $snapshot.panes | Where-Object { $_.pane_id -eq $PaneId }
    if (-not $pane) {
        Write-Host "herdr-layout: unknown pane $PaneId" -ForegroundColor Red
        return
    }

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

    herdr tab rename $tabId editor | Out-Null

    # An unnamed tab's label is its position ("1", "2"), never a companion name,
    # so matching on label is enough to tell an existing companion tab apart from
    # an untouched one. Without this, rerunning on a tab whose sidebar had been
    # closed would stack up a second set of agents/tools tabs.
    $existingLabels = $snapshot.tabs |
        Where-Object { $_.workspace_id -eq $workspaceId } |
        ForEach-Object { $_.label }

    foreach ($label in $script:HerdrCompanionTabs) {
        if ($existingLabels -contains $label) { continue }

        # --no-focus keeps the editor tab in front; the companions are set up
        # behind it and switched to with the normal tab keybindings.
        $tabArgs = @('--label', $label, '--no-focus')
        if ($workspaceId) { $tabArgs += @('--workspace', $workspaceId) }
        if ($Cwd) { $tabArgs += @('--cwd', $Cwd) }

        herdr tab create @tabArgs | Out-Null
    }
}
