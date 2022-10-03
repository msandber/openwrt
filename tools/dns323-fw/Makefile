#
# Copyright (C) 2022 Mauri Sandberg
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=dns323-fw
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=svn
PKG_SOURCE_URL=svn://svn.code.sf.net/p/alt-f/code/tags/Release-1.0/package/alt-f-utils/alt-f-utils-0.1.10/
PKG_SOURCE_VERSION:=3929
PKG_MIRROR_HASH=66045950e95db9862993ac5b449257e6db3262ccc90689073599b83a9feca345
HOST_BUILD_PARALLEL := 1

include $(INCLUDE_DIR)/host-build.mk

define Host/Install
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/dns323-fw $(STAGING_DIR_HOST)/bin/
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOST)/bin/dns323-fw
endef

$(eval $(call HostBuild))
