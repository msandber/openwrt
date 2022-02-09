# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/image.mk

define Build/mkfwimage
	$(STAGING_DIR_HOST)/bin/mkfwimage \
		-B $(1).$(VERSION_DIST).$(REVISION) \
		-k $(IMAGE_KERNEL) \
		-r $(IMAGE_ROOTFS) \
		-o $@.new && \
	mv $@.new $@
endef

define Build/combined-image
	-sh $(TOPDIR)/scripts/combined-image.sh \
		"$(IMAGE_KERNEL)" \
		"$(IMAGE_ROOTFS)" \
		"$@.new" && \
	mv $@.new $@
endef

define Build/mkmylofw
	$(STAGING_DIR_HOST)/bin/mkmylofw -B $(1) \
		-p0x020000:0x130000:ah:0x80041000:linux:$(IMAGE_KERNEL) \
		-p0x150000:0x2a0000:::rootfs:$(IMAGE_ROOTFS) \
		$@.new && \
	mv $@.new $@
endef

define Build/gzip-kernel
	gzip -9n -c $@ > $@.gz
	dd if=$@.gz of=$@ bs=65536 conv=sync
endef

define Build/lzma-kernel
	$(STAGING_DIR_HOST)/bin/lzma e $@ $@.l7
	dd if=$@.l7 of=$@ bs=65536 conv=sync
endef

define Build/copy-kernel
	rm -f $@ $@.elf
	cp $< $@
	cp $< $@.elf
endef

define Build/elf-kernel
	cp $(IMAGE_KERNEL).elf $@
endef

define Device/Default
  PROFILES = Default $$(DEVICE_NAME)
  KERNEL := copy-kernel | lzma-kernel
  IMAGES := sysupgrade.bin
  FILESYSTEMS := squashfs
endef

define Device/generic
  DEVICE_VENDOR := Marvell
  DEVICE_MODEL := Generic Marvell 88F5181 board
  IMAGES := kernel.lzma kernel.elf kernel.gz rootfs.bin sysupgrade.bin
  IMAGE/kernel.gz := elf-kernel | gzip-kernel
  IMAGE/kernel.elf := elf-kernel
  IMAGE/kernel.lzma := elf-kernel | lzma-kernel
  IMAGE/rootfs.bin := append-rootfs | pad-rootfs | pad-to 128k
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | pad-to 128k | combined-image
  DEVICE_IMG_NAME = $$(DEVICE_IMG_PREFIX)-$$(if $$(findstring kernel,$$(2)),,$$(1)-)$$(2)
endef
TARGET_DEVICES += generic

define Device/dlink_dns323
  DEVICE_VENDOR := D-Link
  DEVICE_MODEL := DNS-323
  IMAGE/sysupgrade.bin := append-rootfs | pad-rootfs | pad-to 128k
#  DEFAULT := n
endef
TARGET_DEVICES += dlink_dns323

$(eval $(call BuildImage))
