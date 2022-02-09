include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=orion
BOARDNAME:=Marvell Orion
CPU_TYPE:=xscale 
DEVICE_TYPE:=nas
FEATURES:=rtc low_mem small_flash squashfs ramdisk usb gpio

KERNEL_PATCHVER:=5.10

include $(INCLUDE_DIR)/target.mk
KERNELNAME:=zImage

DEFAULT_PACKAGES += kmod-gpio-button-hotplug

$(eval $(call BuildTarget))
