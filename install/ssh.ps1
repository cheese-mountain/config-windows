# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the SSH service
Start-Service sshd

# Set the SSH service to start automatically on boot
Set-Service -Name sshd -StartupType 'Automatic'

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

Enable-NetFirewallRule -Name "OpenSSH-Server-In-TCP"
