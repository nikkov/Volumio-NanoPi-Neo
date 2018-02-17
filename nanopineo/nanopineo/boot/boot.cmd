# Recompile with:
# mkimage -C none -A arm -T script -d boot.cmd boot.scr

setenv fsck.repair yes

setenv kernel_addr 0x46000000
setenv initrd_addr 0x47000000
setenv dtb_addr 0x48000000

fatload mmc 0 ${initrd_addr} volumio.initrd
fatload mmc 0 ${kernel_addr} zImage
fatload mmc 0 ${dtb_addr} sun8i-${cpu}-${board}.dtb
fdt addr ${dtb_addr}

# setup MAC address 
fdt set ethernet0 local-mac-address ${mac_node}

# setup boot_device
fdt set mmc${boot_mmc} boot_device <1>

setenv fbcon map:0
setenv bootargs console=ttyS0,115200 earlyprintk rootwait imgpart=/dev/mmcblk0p2 imgfile=/volumio_current.sqsh fsck.repair=${fsck.repair} fbcon=${fbcon}
bootz ${kernel_addr} ${initrd_addr}:503000 ${dtb_addr}
