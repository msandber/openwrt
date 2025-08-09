
[ "$INTERFACE" = "wan" ] || exit 0
[ "$ACTION" = "ifup" ] || exit 0

/installer/install.sh &
