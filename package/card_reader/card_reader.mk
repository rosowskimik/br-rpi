################################################################################
#
# Card reader
#
################################################################################
CARD_READER_VERSION = 1f08474d492b13b47e76b0c30cbc618188ca2f9f
CARD_READER_SITE = $(call github,rosowskimik,card_reader,$(CARD_READER_VERSION))
CARD_READER_LICENSE = MIT
CARD_READER_LICENSE_FILES = LICENSE


define CARD_READER_INSTALL_CONFIG
	$(INSTALL) -D -m 644 $(CARD_READER_PKGDIR)/config_template.yml \
		$(TARGET_DIR)/etc/xdg/card_reader/config.yml

	$(SED) 's#@INIT_LOCKED@#$(if $(BR2_PACKAGE_CARD_READER_INIT_LOCKED),true,false)#' \
		-e 's#@SYSTEM_ID@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_SYSTEM_ID))#' \
		-e 's#@INTERFACE@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_INTERFACE))#' \
		-e 's#@HOSTNAME@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_HOSTNAME))#' \
		-e 's#@RED_LED@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_RED_LED))#' \
		-e 's#@GREEN_LED@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_GREEN_LED))#' \
		-e 's#@STRENGTH@#$(BR2_PACKAGE_CARD_READER_STRENGTH)#' \
		-e 's#@CARD_TIMEOUT@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_CARD_TIMEOUT))#' \
		-e 's#@MOVEMENT_TIMEOUT@#$(call qstrip,$(BR2_PACKAGE_CARD_READER_MOVEMENT_TIMEOUT))#' \
		$(TARGET_DIR)/etc/xdg/card_reader/config.yml
endef
CARD_READER_POST_INSTALL_TARGET_HOOKS += CARD_READER_INSTALL_CONFIG

define CARD_READER_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 755 $(CARD_READER_PKGDIR)/S99card_reader \
		$(TARGET_DIR)/etc/init.d/S99card_reader
endef

$(eval $(golang-package))
