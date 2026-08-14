# Run from a herdr popup (prefix+t). A popup is its own process, so it cannot
# Set-Location the pane that opened it - a child cannot change a sibling's cwd.
# Instead it picks the directory, then types the cd into the originating pane.
# The popup closes on its own as soon as this script exits.

. "$PSScriptRoot\fd.ps1"
. "$PSScriptRoot\herdr-layout.ps1"

$selectedDir = Select-RepoDir
if (-not $selectedDir) { return }   # user pressed Esc

# A popup is session-modal and stays out of the tab layout, so the snapshot's
# focused_pane_id still refers to the pane underneath it.
$origin = (herdr api snapshot | ConvertFrom-Json).result.snapshot.focused_pane_id

if (-not $origin -or $origin -eq $env:HERDR_PANE_ID) {
    # Sending to our own pane would type into the popup as it closes. Surface the
    # reason instead of failing silently, and hold long enough to read it.
    Write-Host "herdr-fd: could not resolve the originating pane" -ForegroundColor Red
    Write-Host "  focused=$origin self=$env:HERDR_PANE_ID" -ForegroundColor DarkGray
    Start-Sleep -Seconds 4
    return
}

herdr pane send-text $origin "Set-Location '$selectedDir'" | Out-Null
herdr pane send-keys $origin enter | Out-Null

# The cd above is typed, so it lands whenever the origin pane's shell gets to it.
# The layout does not wait for that: the new panes are given the directory
# directly rather than inheriting it from the pane.
Set-HerdrLayout -PaneId $origin -Cwd $selectedDir
