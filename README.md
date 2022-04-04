# wxp-installer-for-winpe
A simpler way to install Windows XP using the Windows Preinstalled Environment (WinPE), designed for USB flash drives.

# How to use
This is the Windows XP Installer For WinPE developed by NTVMB. It is a simple solution to install Windows XP from a USB flash drive.
This tool will guide you through preparing the Windows XP setup.

You will need two things:
A Windows Vista-8.1 installer ISO or a WinPE ISO using a Windows Vista-8.1 kernel (Windows 10 and newer do not work)
A Windows XP ISO

Before you can begin, prepare the USB drive to install Windows XP.
- Create a bootable WinPE USB. Several tools are available to do this.
- Extract your Windows XP ISO to the root directory of your WinPE USB.
- Copy this tool's files to your WinPE USB (preferably the root directory).

Once you have finished these tasks, you can now boot to your WinPE USB.
WARNING: Some computers, particularly older computers, do not support booting from USB flash drives. Double-check that your computer can boot from USB drives before proceeding.
Navigate to your WinPE USB and run INSTALL.BAT.
If any other drive is already mounted as C:, the tool will automatically unmount the drive.
From here, the tool will launch DISKPART so you can partition and format the disks, but make sure to mount the partition Windows will be installed on as the C: drive.
Once you have finished partitoning the disks, the installation should be straightforward.
