#!/bin/sh

. /lib/functions.sh

include /lib/upgrade

. /usr/share/libubox/jshn.sh

export VERBOSE=1

if [ ! -d /etc/ssl/certs/ ]; then
    WGET_OPTS="--no-check-certificate"
fi

case "$(board_name)" in
    dna,valokuitu-plus-ex400)
        . /installer/do_dna_valokuitu_plus_ex400.sh
        ;;
    genexis,pulse-ex400)
        . /installer/do_genexis_pulse_ex400.sh
        ;;
    *)
        echo "Incompatible board $(board_name)" >&2
        exit 1
        ;;
esac

download_image(){
    local site=$1
    local filename=$2
    local sha256=$3

    echo wget ${WGET_OPTS} -q "$site/$filename"
    wget ${WGET_OPTS} -qO $filename "$site/$filename" || exit 1

    sha256local=$(sha256sum "$filename" | cut -d ' ' -f1)
    if [ "$sha256" != "$sha256local" ]; then
            echo "Downloaded image checksum mismatch" >&2
            exit 1
    fi
}

cd /tmp

download_image "$SITE" "$FILE_REC" "$SHA_REC"
download_image "$SITE" "$FILE_FIT" "$SHA_FIT"
download_image "$SITE" "$FILE_UBOOT" "$SHA_UBOOT"

ln -s /tmp/$FILE_REC /tmp/mt7621_rec
ln -s /tmp/$FILE_FIT /tmp/mt7621_fit
ln -s /tmp/$FILE_UBOOT /tmp/mt7621_uboot

echo $(board_name) >> /tmp/board_name

install_bin /sbin/upgraded
install_bin /usr/bin/tr
cp /installer/install_2nd.sh /tmp

RAM_ROOT="/tmp/root"
COMMAND="sh /tmp/install_2nd.sh"
SAVE_PARTITIONS=0

json_init
json_add_string prefix "$RAM_ROOT"
json_add_string path "/tmp/"
json_add_boolean force 1
json_add_string command "$COMMAND"
json_add_object options
json_add_int save_partitions "$SAVE_PARTITIONS"
json_close_object

ubus call system sysupgrade "$(json_dump)"
