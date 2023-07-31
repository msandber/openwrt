#
# Copyright (C) 2023 Mauri Sandberg
#

# The vendor ubi is split in ubifs volumes 0-3 and the vendor root
# filesystems are in volumes 2 (rootfs_0) and 3 (rootfs_1). Drop them and
# explicitly use rootfs_0 as a boot partition that contains the dtb and the
# OpenWrt kernel. This is because the u-boot expects to find them there.
# Then continue upgrade with the default method and a squashfs rootfs will be
# installed and the rest of ubifs will be used as overlay

# The 'kernel' inside the sysupgrage.tar is an ubifs that contains /boot/dtb
# and /boot/kernel. The 'root' is an OpenWrt squashfs root

. /lib/functions.sh
. /lib/upgrade/nand.sh

dna_do_upgrade () {
	tar -xaf $1

	# get the size of the new bootfs
	local _bootfs_size=$(wc -c < ./sysupgrade-dna_valokuitu-plus-ex400/kernel)
	[ -n "$_bootfs_size" -a "$_bootfs_size" -gt "0" ] || nand_do_upgrade_failed

	# remove existing rootfses and recreate rootfs_0
	ubirmvol /dev/ubi0 --name=rootfs_0 > /dev/null 2>&1
	ubirmvol /dev/ubi0 --name=rootfs_1 > /dev/null 2>&1
	ubirmvol /dev/ubi0 --name=rootfs > /dev/null 2>&1
	ubirmvol /dev/ubi0 --name=rootfs_data > /dev/null 2>&1
	ubimkvol /dev/ubi0 --type=static --size=${_bootfs_size} --name=rootfs_0

	# update the rootfs_0 contents
	local _kern_ubivol=$( nand_find_volume "ubi0" "rootfs_0" )
	ubiupdatevol /dev/${_kern_ubivol} sysupgrade-dna_valokuitu-plus-ex400/kernel

	fw_setenv root_vol rootfs_0
	fw_setenv boot_cnt_primary 0
	fw_setenv boot_cnt_alt 0

	# proceed to upgrade the default way
	CI_KERNPART=none
	nand_do_upgrade "$1"
}
