Build script and firmware for Volumio images for FriendlyArm's Allwinner H3/H5 boards: NanoPi-Neo, NanoPi-Neo Air and NanoPi-Neo2
(http://www.friendlyarm.com/index.php?route=product/category&path=69)

1. Prerequisites for build Allwinner H5 nanopi-neo2 platform.
(source URL: http://wiki.friendlyarm.com/wiki/index.php/Mainline_U-boot_and_Linux)

Install Cross Compiler
- Visit here download link (https://drive.google.com/drive/folders/1NudJtkAq4fYil0q-kTidKOE69G4Xk9Uj)
  and download the cross compiler gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz 

- extract it:
$ mkdir -p /opt/FriendlyARM/toolchain
$ tar xf gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu.tar.xz -C /opt/FriendlyARM/toolchain/

- Add the compiler's path to the "PATH" variable by appending the following lines in the ~/.bashrc file:
$ export PATH=/opt/FriendlyARM/toolchain/gcc-linaro-6.3.1-2017.02-x86_64_aarch64-linux-gnu/bin:$PATH
$ export GCC_COLORS=auto

- Run the ~/.bashrc script to make the changes in effect immediately in your working shell. 
  Attention: there is a space after ".":
$ . ~/.bashrc
  
- You can check whether or not your compiler is setup correctly by running the following commands:
$ aarch64-linux-gnu-gcc -v
gcc version 6.3.1 20170109 (Linaro GCC 6.3-2017.02)


2. Prerequisites for build Allwinner H3 nanopi-neo(air) platform
(source URL: http://wiki.friendlyarm.com/wiki/index.php/Mainline_U-boot_and_Linux)

- Visit here download link (https://drive.google.com/drive/folders/1QQjj51DnSyDGQhwUsIn9UsZgSz6u7xlU)
  and download the cross compiler:arm-cortexa9-linux-gnueabihf-4.9.3.tar.xz 
- and extract it:
$ mkdir -p /opt/FriendlyARM/toolchain
$ tar xf arm-cortexa9-linux-gnueabihf-4.9.3.tar.xz -C /opt/FriendlyARM/toolchain/

- Add the compiler's path to the "PATH" variable by appending the following lines in the ~/.bashrc file:

$ export PATH=/opt/FriendlyARM/toolchain/4.9.3/bin:$PATH
$ export GCC_COLORS=auto
- Run the ~/.bashrc script to make the changes in effect immediately in your working shell. 
  Attention: there is a space after ".":
$ . ~/.bashrc

This is a 64-bit compiler and it cannot run on a 32-bit Linux. You can check whether or not your compiler is setup correctly by running the following commands:

$ arm-linux-gcc -v
gcc version 4.9.3 (ctng-1.21.0-229g-FA)

