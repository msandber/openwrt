# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

ROOTFS_PARTSIZE := 6336k
KERNEL_LOADADDR := 0x8000
RAMDISK_LOADADDR := 0x800000

define Build/rename_tmp
	mv $@ $(KDIR_TMP)/$1
endef

define Build/cpiogz
	( cd $(TARGET_DIR); find . | cpio -o -H newc | gzip -9n > $@.new )
	mv $@.new $@
endef

define Build/uRamdisk
	mkimage -A arm -O linux -T ramdisk -C none \
		-e $(RAMDISK_LOADADDR) -a $(RAMDISK_LOADADDR) \
		-n "Maukka ramdisk" -d $@ $@.new
	mv $@.new $@
endef

define Build/dns323-fw
	$(eval _kernel=$(KDIR_TMP)/$(word 1,$(1)))
	$(eval _rootfs=$(KDIR_TMP)/$(word 2,$(1)))
	$(STAGING_DIR_HOST)/bin/dns323-fw \
		-m -p 7 -c 1 -l 1 \
		-u 1 -v 4 -t 0 \
		-k $(_kernel) -i $(_rootfs) $@.new
#	rm -rf $(_kernel) $(_rootfs)
	mv $@.new $@
endef

define Device/Default
  PROFILES := Default
#  DEVICE_DTS = orion5x-$(lastword $(subst _, ,$(1)))
#  KERNEL_DEPENDS = $$(wildcard $(DTS_DIR)/$$(DEVICE_DTS).dts)
#  KERNEL := kernel-bin | append-dtb | uImage none
  KERNEL := kernel-bin | uImage none
  KERNEL_NAME := zImage
  KERNEL_SUFFIX  := -uImage
  BLOCKSIZE := 64k
  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef

define Device/dlink_dns323
  DEVICE_VENDOR := D-Link
  DEVICE_MODEL := DNS-323
  DEVICE_PACKAGES := kmod-gpio-button-hotplug kmod-usb2
  IMAGES := sysupgrade.bin factory.bin kernel.img rootfs.img
  IMAGE/sysupgrade.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | append-rootfs |\
  	pad-rootfs | check-size
  IMAGE/factory.bin := append-kernel | pad-to $$$$(BLOCKSIZE) | rename_tmp part_1 | cpiogz | uRamdisk | pad-rootfs | rename_tmp part_2 | dns323-fw part_1 part_2
  IMAGE/kernel.img := append-kernel | pad-to $$$$(BLOCKSIZE)
  IMAGE/rootfs.img := cpiogz | uRamdisk | pad-rootfs
endef
TARGET_DEVICES += dlink_dns323

$(eval $(call BuildImage))
