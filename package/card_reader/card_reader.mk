################################################################################
#
# Card reader
#
################################################################################
CARD_READER_VERSION = fa7d1a66cc8cb6e70ba0339286fafcb6860e8ebe
CARD_READER_SITE = $(call github,rosowskimik,card_reader,$(CARD_READER_VERSION))
CARD_READER_LICENSE = MIT
CARD_READER_LICENSE_FILES = LICENSE


define CARD_READER_INSTALL_CONFIG
	$(INSTALL) -D -m 644 $(CARD_READER_PKGDIR)/default_config.yml \
		$(TARGET_DIR)/etc/xdg/card_reader/config.yml

	$(SED) 's/localhost/$(call qstrip,$(BR2_PACKAGE_CARD_READER_HOSTNAME))/' \
		$(TARGET_DIR)/etc/xdg/card_reader/config.yml
endef
CARD_READER_POST_INSTALL_TARGET_HOOKS += CARD_READER_INSTALL_CONFIG

define CARD_READER_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(CARD_READER_PKGDIR)/S99card_reader \
		$(TARGET_DIR)/etc/init.d/S99card_reader
endef

$(eval $(golang-package))
