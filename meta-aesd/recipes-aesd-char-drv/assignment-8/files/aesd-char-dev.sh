#!/bin/sh


aesd_load ()
{
    module=aesdchar
    device=aesdchar
    mode="664"
    cd `dirname $0`
    set -e
    # Group: since distributions do it differently, look for wheel or use staff
    if grep -q '^staff:' /etc/group; then
        group="staff"
    else
        group="wheel"
    fi

    if [ -e ${module}.ko ]; then
        echo "Loading local built file ${module}.ko"
        insmod ./$module.ko $* || exit 1
    else
        echo "Local file ${module}.ko not found, attempting to modprobe"
        modprobe ${module} || exit 1
    fi
    major=$(awk "\$2==\"$module\" {print \$1}" /proc/devices)
    rm -f /dev/${device}
    mknod /dev/${device} c $major 0
    chgrp $group /dev/${device}
    chmod $mode  /dev/${device}
}

aesd_unload()
{
    module=aesdchar
    device=aesdchar
    cd `dirname $0`
    # invoke rmmod with all arguments we got
    rmmod $module || exit 1

    # Remove stale nodes

    rm -f /dev/${device}
}

cd /lib/modules/$(uname -r)/extra
depmod
case "$1" in
    start)
        aesd_load
        ;;
    stop)
        aesd_unload
        ;;
    *)
        echo "Usage: $0 {start | stop}"
        exit 1
esac

exit 0