$repo = Split-Path $PSScriptRoot -Parent

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    return (New-Object Security.Principal.WindowsPrincipal $identity).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-Not (Test-Admin)) {
    Write-Host "Not running as admin - registering autostart tasks with highest privileges needs admin." -ForegroundColor Yellow
}

Write-Host "`nRegistering startup tasks..." -ForegroundColor Cyan

# Run at logon, as the current user, with highest privileges (admin) so the AHK
# remaps can intercept keys in elevated windows and the quake terminal starts
# elevated. RunLevel Highest is why this whole step needs admin.
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" `
    -LogonType Interactive -RunLevel Highest
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)

function Register-StartupTask($name, $exe, $argument) {
    if (-Not (Test-Path $exe)) {
        Write-Host "  skip  $name ($exe not found)" -ForegroundColor DarkGray
        return
    }
    # -Argument rejects null/empty, so only pass it when there is one.
    $action = if ($argument) {
        New-ScheduledTaskAction -Execute $exe -Argument $argument
    }
    else {
        New-ScheduledTaskAction -Execute $exe
    }
    try {
        Register-ScheduledTask -TaskName $name -Action $action -Trigger $trigger `
            -Principal $principal -Settings $settings -Force -ErrorAction Stop | Out-Null
        Write-Host "  task  $name" -ForegroundColor Green
    }
    catch {
        Write-Host "  fail  $name ($($_.Exception.Message))" -ForegroundColor Red
    }
}

# Windows Terminal
$wt = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\wt.exe"
Register-StartupTask "config-terminal" $wt

# AutoHotkey remaps (path resolved from this repo, not hardcoded)
$ahkExe = "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"
$ahkScript = Join-Path $repo "windows\remaps.ahk"
Register-StartupTask "config-ahk-remaps" $ahkExe "`"$ahkScript`""
