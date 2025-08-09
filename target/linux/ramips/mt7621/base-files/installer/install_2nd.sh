#!/bin/sh

FILE_REC="/tmp/mt7621_rec"
FILE_FIT="/tmp/mt7621_fit"
FILE_UBOOT="/tmp/mt7621_uboot"

BOARD=$(cat /tmp/board_name)

initial_check(){
    [ -f "$FILE_FIT" ] || exit 1
    [ -f "$FILE_REC" ] || exit 1
    [ -f "$FILE_UBOOT" ] || exit 1

    # prepare empty file of size 0x1f000
    dd if=/dev/zero bs=1024 count=124 | tr '\000' '\377' | dd of=/tmp/empty_1f000 bs=1024
}

remove_existing_volumes(){
    # skip 0 and 1 because env1 and env 2 reside there
    for num in 2 3 4 5 6 7; do
        ubirmvol /dev/ubi0 -n $num
    done > /tmp/mac_bin
}

prepare_factory(){
    local ethaddr=$(fw_printenv ethaddr | cut -d '=' -f2)
    eth_nums=$(echo $ethaddr | tr ':' ' ')

    for num in $eth_nums; do
        printf "\\x$num"
    done > /tmp/mac_bin

    cp /tmp/empty_1f000 /tmp/factory_bin
    dd if=/tmp/mac_bin bs=1 count=6 of=/tmp/factory_bin conv=notrunc

    ubimkvol /dev/ubi0 -n 2 -N factory -s 0x1f000 || exit 1
    ubiupdatevol /dev/ubi0_2 /tmp/factory_bin
}

prepare_uboot_env(){
    [ -e /dev/ubi0_0 ] || ubimkvol /dev/ubi0 -n 0 -N env1 -s 0x1f000 || exit 1
    [ -e /dev/ubi0_1 ] || ubimkvol /dev/ubi0 -n 1 -N env2 -s 0x1f000 || exit 1

    ubiupdatevol /dev/ubi0_0 /tmp/empty_1f000
    ubiupdatevol /dev/ubi0_1 /tmp/empty_1f000
}

prepare_recovery(){
    local filesize=$(wc -c < $FILE_REC)

    ubimkvol /dev/ubi0 -n 3 -N recovery -s $filesize || exit 1
    ubiupdatevol /dev/ubi0_3 $FILE_REC
}

prepare_fit(){
    local filesize=$(wc -c < $FILE_FIT)

    ubimkvol /dev/ubi0 -n 4 -N fit -s $filesize || exit 1
    ubiupdatevol /dev/ubi0_4 $FILE_FIT
}

upgrade_uboot(){
    mtd erase /dev/mtd0
    mtd write $FILE_UBOOT /dev/mtd0
}

prepare_rootfs_data(){
    ubimkvol /dev/ubi0 -n 5 -N rootfs_data -m || exit 1
}

initial_check
remove_existing_volumes
prepare_factory
prepare_recovery
prepare_fit
prepare_uboot_env
upgrade_uboot
prepare_rootfs_data

umount -a
reboot -f
sleep 5
echo b 2>/dev/null >/proc/sysrq-trigger
