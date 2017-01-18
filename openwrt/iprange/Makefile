include $(TOPDIR)/rules.mk

PKG_NAME:=iprange
PKG_VERSION:=<<VER>>
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/iprange-$(PKG_VERSION)
PKG_SOURCE:=iprange-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=<<URL>>
PKG_MD5SUM:=<<MD5>>
PKG_CAT:=bzcat

include $(INCLUDE_DIR)/package.mk

define Package/iprange
	SECTION:=utils
	CATEGORY:=Utilities
	DEPENDS:=+libpthread
	TITLE:=iprange - minimise lists of IP addresses
	URL:=https://firehol.org/
endef

define Package/iprange/description
	IP list minimisation utility
	Creates a minimal set of IP address ranges from an arbitrary input
endef

define Build/Configure
  $(call Build/Configure/Default)
endef

define Package/iprange/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/iprange $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iprange))
