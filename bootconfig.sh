#!/bin/bash

systemctl set-default multi-user.target

if ! grep "1-3" /sys/devices/system/cpu/isolated; then
    if ! grep "isolcpus=1-3" /boot/firmware/cmdline.txt; then
        sed -i 's/\(^.*root=.*\)$/\1 isolcpus=1-3/' /boot/firmware/cmdline.txt
    fi
fi
