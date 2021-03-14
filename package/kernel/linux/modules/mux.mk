# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

MUX_MENU:=Multiplexer Support

define KernelPackage/mux-gpio
  SUBMENU:=$(MUX_MENU)
  TITLE:=MUX GPIO
  KCONFIG:=CONFIG_MUX_GPIO \
           CONFIG_MULTIPLEXER=y
  DEPENDS:=
  FILES:=\
         $(LINUX_DIR)/drivers/mux/core.ko \
         $(LINUX_DIR)/drivers/mux/gpio.ko
  AUTOLOAD:=$(call AutoProbe,core gpio)
endef

define KernelPackage/mux-gpio/description
  Kernel modules for GPIO multiplexer
endef

$(eval $(call KernelPackage,mux-gpio))
