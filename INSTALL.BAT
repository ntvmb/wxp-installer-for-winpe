@echo off
rem Windows XP Installer For WinPE
title Windows XP Installer
cls
if "%~1"=="" (
  set TEMPLOCATION=.
  goto start
)
if /i "%~1"=="/templocation" (
  if "%~2"=="" (
    goto error9
  ) else (
    set TEMPLOCATION=%2
  )
)
:start
echo Windows XP Installer for WinPE v1.1.0-pre4
::Quick check for Windows PE
if not exist X:\Windows\System32\wpeutil.exe goto error4
::Check Windows kernel version
setlocal
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if %VERSION% GTR 6.3 goto error5
endlocal
::Check for Windows XP installation files
if not exist \I386\* goto error
::Check if another drive is already mounted as C:.
echo Unmount drive C: if another drive is already mounted there.
mountvol C: /d
echo Partition and format disks...
:partition
echo How do you want to partition the disks?
echo 1 = Guided (Not yet implemented)
echo 2 = Manual (Advanced)
echo 3 = Quit setup
set /p PARTSETUPTYPE=
if %PARTSETUPTYPE% == 1 goto guided_part
if %PARTSETUPTYPE% == 2 goto manual_part
if %PARTSETUPTYPE% == 3 exit /b
echo Error 0x05: Invalid response. Must be a number between 1 and 3.
goto partition

:install
echo Begin Windows XP installation...
START /WAIT \I386\WINNT32.EXE /SYSPART:C: /TEMPDRIVE:C: /MAKELOCALSOURCE
if exist \i386\setuporg.exe xcopy \i386\setuporg.exe C:\$WIN_NT$.~LS\I386\ && if exist \i386\presetup.cmd xcopy \i386\presetup.cmd C:\$WIN_NT$.~LS\I386\
if exist \OEM (mkdir C:\OEM && xcopy /s \OEM C:\OEM)
if exist %TEMPLOCATION%\diskpart.script del %TEMPLOCATION%\diskpart.script
echo Restarting computer...
wpeutil reboot
exit /b

:guided_part
echo test > %TEMPLOCATION%\testfile
if not exist %TEMPLOCATION%\testfile goto error7
del %TEMPLOCATION%\testfile
if exist %TEMPLOCATION%\diskpart.script.tmp del %TEMPLOCATION%\diskpart.script.tmp
echo lis dis > %TEMPLOCATION%\diskpart_tmp.script
diskpart /s %TEMPLOCATION%\diskpart_tmp.script
del %TEMPLOCATION%\diskpart_tmp.script
echo I have retrieved the list of disks.
:sel_disk
if exist %TEMPLOCATION%\diskpart.script.tmp del %TEMPLOCATION%\diskpart.script.tmp
set /p DISK_TO_PARTITION=Select the disk to partition... (Default: 0) 
if not defined DISK_TO_PARTITION set DISK_TO_PARTITION=0
echo sel dis %DISK_TO_PARTITION% >%TEMPLOCATION%\diskpart.script.tmp
echo Checking for selected disk...
diskpart /s %TEMPLOCATION%\diskpart.script.tmp >nul
if %errorlevel% NEQ 0 (echo Error 0x07: Selected disk does not exist. && goto sel_disk)
:how_to_partition
echo How do you want to configure the disk?
echo 1 = Erase/Use entire disk
echo 2 = Use manual partitioning ^(Advanced^)
echo 3 = Quit setup
set /p %HOWTOPARTITION%=
if %HOWTOPARTITION% == 1 (
  echo clean >> %TEMPLOCATION%\diskpart.script.tmp
  echo cre par pri >> %TEMPLOCATION%\diskpart.script.tmp
  echo form quick fs=ntfs >> %TEMPLOCATION%\diskpart.script.tmp
  echo assign letter c >> %TEMPLOCATION%\diskpart.script.tmp
  goto start_partitioning
)
if %HOWTOPARTITION% == 2 goto manual_part
if %HOWTOPARTITION% == 3 exit /b
echo Error 0x05: Invalid response. Must be a number between 1 and 3.
goto how_to_partition
:start_partitioning
echo The following operations are going to be performed:
if %HOWTOPARTITION% == 1 (
  echo Delete any partitions on the disk
  echo Create primary partition on disk %DISK_TO_PARTITION%
  echo Format partition 1 as NTFS
  echo Assign partition to C:
  set /p ans=Write changes to disk? ^(Y/n^)
  if %ans% == Y (
  move %TEMPLOCATION%\diskpart.script.tmp %TEMPLOCATION%\diskpart.script
  diskpart /s %TEMPLOCATION%\diskpart.script
  goto install
) else goto guided_part

:manual_part
if exist %TEMPLOCATION%\diskpart.script.tmp del %TEMPLOCATION%\diskpart.script.tmp
echo Note: Mount the partition you want to install Windows on as C:.
diskpart
if not exist C:\ goto error2
::Redundant write test
echo test > C:\testfile
if not exist C:\testfile goto error3
del C:\testfile
goto install

:error
echo Fatal Error 0x00:
echo I cannot find your Windows XP installation files. Is the installer placed in the drive containing your Windows XP files?
echo Make sure to place the Windows XP files in the root directory of your USB drive.
echo The installer cannot continue.
pause
exit /b

:error2
echo Error 0x01:
echo A partition must be mounted as C: and formatted as FAT32 or NTFS to install Windows.
pause
cls
goto manual_part

:error3
echo Error 0x02:
echo Cannot write to C:! Make sure you formatted the drive and it is not write-protected.
pause
cls
goto manual_part

:error4
echo Fatal Error 0x03:
echo This utility must be run from the Windows Preinstalled Environment. The installer cannot continue.
pause
exit /b

:error5
echo Fatal Error 0x04:
echo Your kernel is too new to install Windows XP from. The installer cannot continue.
pause
exit /b

:error7
echo Error 0x06:
echo Cannot create temporary files. I require a non-write-protected medium.
echo Entering manual partitioning...
goto manual_part

:error9
echo Error 0x08:
echo Invalid syntax for switch %1. The installer cannot continue.
exit /b
