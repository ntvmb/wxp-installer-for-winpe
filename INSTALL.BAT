@echo off
rem Windows XP Installer For WinPE
title Windows XP Installer
cls
echo Windows XP Installer for WinPE v1.1.0-gitcommit6
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
echo Restarting computer...
wpeutil reboot
exit /b

:guided_part
echo As of now, guided partitioning is not yet implemented.
echo Entering manual partitioning...
goto manual_part
echo test > testfile
if not exist testfile goto error7
del testfile
echo lis dis > diskpart_tmp.script
diskpart /s diskpart_tmp.script
del diskpart_tmp.script
echo I have retrieved the list of disks.
:sel_disk
if exist diskpart.script.tmp del diskpart.script.tmp
set /p DISK_TO_PARTITION=Select the disk to partition... (Default: 0) 
if not defined %DISK_TO_PARTITION% set DISK_TO_PARTITION=0
echo sel dis %DISK_TO_PARTITION% >diskpart.script.tmp
echo Checking for selected disk...
diskpart /s diskpart.script.tmp >nul
if %errorlevel% NEQ 0 (echo Error 0x07: Selected disk does not exist. && goto sel_disk)
echo lis par >> diskpart.script.tmp
set PARTITION_COUNT=0
for /f "eol=T skip=10 delims=x tokens=1-13" %%I in ('diskpart /s diskpart.tmp') do (echo %%I && (set /A PARTITION_COUNT=%PARTITION_COUNT%+1 >nul))
:how_to_partition
::Very long lines ahead. These may be hard to understand.
if %PARTITION_COUNT% == 0 (
  echo No previous partitions detected. What do you want to do?
  echo 1 = Use entire disk
  echo 2 = Use manual partitioning (Advanced)
  echo 3 = Quit setup
  set /p %HOWTOPARTITION%=
  if %HOWTOPARTITION% == 1 ((echo cre par pri >> diskpart.script.tmp) && (echo form quick fs=ntfs >> diskpart.script.tmp) && (echo assign letter c >> diskpart.script.tmp) && goto start_partitioning)
  if %HOWTOPARTITION% == 2 goto manual_part
  if %HOWTOPARTITION% == 3 exit /b
  echo Error 0x05: Invalid response. Must be a number between 1 and 3.
  goto how_to_partition
)
if %PARTITION_COUNT% == 1 (
  echo One partition was detected. What do you want to do?
  echo 1 = Erase disk 
  echo 2 = Use manual partitioning (Advanced)
  echo 3 = Quit setup
  set /p %HOWTOPARTITION%=
  if %HOWTOPARTITION% == 1 (
    (echo clean >> diskpart.script.tmp) && (echo cre par pri >> diskpart.script.tmp) && (echo form quick fs=ntfs >> diskpart.script.tmp) && (echo assign letter c >> diskpart.script.tmp) goto start_partitioning
  )
  if %HOWTOPARTITION% == 2 goto manual_part
  if %HOWTOPARTITION% == 3 exit /b
  echo Error 0x05: Invalid response. Must be a number between 1 and 3.
  goto how_to_partition
)
if %PARTITION_COUNT% GTR 1 (
  echo Multiple partitions were detected. What do you want to do?
  echo 1 = Erase disk
  echo 2 = Replace a partition (Not recommended. It might break things)
  echo 3 = Use manual partitioning (Advanced)
  echo 4 = Quit setup
  set /p %HOWTOPARTITION%=
  if %HOWTOPARTITION% == 1 (
    (echo clean >> diskpart.script.tmp) && (echo cre par pri >> diskpart.script.tmp) && goto start_partitioning
  )
  if %HOWTOPARTITION% == 2 (
    set /p PARTTOREPLACE=Partition to replace? (1-%PARTITION_COUNT%) && if defined %PARTTOREPLACE% (
      if %PARTTOREPLACE% LEQ %PARTITION_COUNT% (
        if %PARTTOREPLACE% NEQ 0 (
          (echo sel par %PARTTOREPLACE% >> diskpart.script.tmp) && (echo del par >> diskpart.script.tmp) && (echo cre par pri >> diskpart.script.tmp) && (echo form quick fs=ntfs >> diskpart.script.tmp) && (echo assign letter c >> diskpart.script.tmp) && goto start partitioning
        ) else (
          echo Error 0x05: Invalid response.
        )
      ) else (
        echo Error 0x05: Invalid response.
    ) else (
    echo Error 0x05: Invalid response.
  )
  if %HOWTOPARTITION% == 3 goto manual_part
  if %HOWTOPARTITION% == 4 exit /b
  echo Error 0x05: Invalid response. Must be a number between 1 and 3.
  goto how_to_partition
)

:manual_part
if exist diskpart.script.tmp del diskpart.script.tmp
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
