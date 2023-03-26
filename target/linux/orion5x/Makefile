# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

ARCH := arm
BOARD := orion5x
BOARDNAME := Marvell Orion
DEVICE_TYPE := nas
#FEATURES := dt ramdisk rtc squashfs usb
FEATURES := ramdisk rtc squashfs usb

KERNEL_PATCHVER := 5.4

include $(INCLUDE_DIR)/target.mk

#KERNELNAME := zImage dtbs
KERNELNAME := zImage

DEFAULT_PACKAGES += uboot-envtools

$(eval $(call BuildTarget))
