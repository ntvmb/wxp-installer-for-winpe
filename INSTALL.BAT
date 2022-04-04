@echo off
rem Windows XP Installer For WinPE
title Windows XP Installer
cls
if not exist \I386\* goto error
::Check if another drive is already mounted as C:.
echo Unmount drive C: if another drive is already mounted there.
mountvol C: /d
echo Partition and format disks...
echo Note: Mount the partition you want to install Windows on as C:.
:install
diskpart
if not exist C:\ goto error2
echo test > C:\testfile
if not exist C:\testfile goto error3
del C:\testfile
echo Begin Windows XP installation...
START /WAIT \I386\WINNT32.EXE /SYSPART:C: /TEMPDRIVE:C: /MAKELOCALSOURCE
if exist \i386\setuporg.exe xcopy \i386\setuporg.exe C:\$WIN_NT$.~LS\I386\ && if exist \i386\presetup.cmd xcopy \i386\presetup.cmd C:\$WIN_NT$.~LS\I386\
if exist \OEM (mkdir C:\OEM && xcopy /s \OEM C:\OEM)
echo Restarting computer...
wpeutil reboot
exit

:error
echo Error 1:
echo I cannot find your Windows XP installation files. Is the installer placed in the drive containing your Windows XP files?
echo Make sure to place the Windows XP files in the root directory of your USB drive.
pause
exit

:error2
echo Error 2:
echo A partition must be mounted as C: and formatted as FAT32 or NTFS to install Windows.
pause
cls
goto install

:error3
echo Error 3:
echo Cannot write to C:! Make sure you formatted the drive and it is not write-protected.
pause
cls
goto install