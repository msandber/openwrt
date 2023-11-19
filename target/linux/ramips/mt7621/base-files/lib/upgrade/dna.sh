
. /lib/functions.sh
. /lib/upgrade/nand.sh

_ROOTFS_SIZE=16MiB
_BOARD=dna_valokuitu-plus-ex400
_SYSUP_DIR=sysupgrade-${_BOARD}
_TMP_MOUNT=/tmp/dna_ubi_mount
_UBI_VOL_ROOTFS=/dev/ubi0_3
_UBI_VOL_ROOTFS_DATA=/dev/ubi0_4

do_dna_upgrade () {
	tar -xaf $1

	# clear existing volumes
	[ -e ${_UBI_VOL_ROOTFS} ] && ubirmvol /dev/ubi0 -n 3
	[ -e ${_UBI_VOL_ROOTFS_DATA} ] && ubirmvol /dev/ubi0 -n 4

	# create new volumes
	ubimkvol /dev/ubi0 -s ${_ROOTFS_SIZE} -N rootfs_1
	ubimkvol /dev/ubi0 -m -N rootfs_data

	# update the rootfs with new ubifs image
	ubiupdatevol ${_UBI_VOL_ROOTFS} ${_SYSUP_DIR}/root

	mkdir ${_TMP_MOUNT}
	mount -t ubifs ${_UBI_VOL_ROOTFS} ${_TMP_MOUNT}
	mkdir ${_TMP_MOUNT}/boot
	mv ${_SYSUP_DIR}/kernel ${_TMP_MOUNT}/boot/uImage
	mv ${_SYSUP_DIR}/dtb ${_TMP_MOUNT}/boot/dtb
	sync
	umount ${_TMP_MOUNT}

	nand_do_upgrade_success
}
