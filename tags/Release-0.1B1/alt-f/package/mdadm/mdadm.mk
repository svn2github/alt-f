#############################################################
#
# mdadm
#
#############################################################
#MDADM_VERSION:=2.6.7.1
# jc: uclibc must be compiled with UCLIBC_HAS_ADVANCED_REALTIME, else posix_memalign() is missing
MDADM_VERSION:=3.1.1
MDADM_SOURCE:=mdadm-$(MDADM_VERSION).tar.gz
# jc: MDADM_SOURCE:=mdadm_$(MDADM_VERSION).orig.tar.gz
# jc: MDADM_PATCH:=mdadm_$(MDADM_VERSION)-1.diff.gz
MDADM_CAT:=$(ZCAT)
# jc: MDADM_SITE:=$(BR2_DEBIAN_MIRROR)/debian/pool/main/m/mdadm
MDADM_SITE:=http://www.kernel.org/pub/linux/utils/raid/mdadm/
MDADM_DIR:=$(BUILD_DIR)/mdadm-$(MDADM_VERSION)
MDADM_BINARY:=mdadm
MDADM_TARGET_BINARY:=sbin/mdadm

ifneq ($(MDADM_PATCH),)
MDADM_PATCH_FILE:=$(DL_DIR)/$(MDADM_PATCH)
$(MDADM_PATCH_FILE):
	$(call DOWNLOAD,$(MDADM_SITE),$(MDADM_PATCH))
endif

$(DL_DIR)/$(MDADM_SOURCE): $(MDADM_PATCH_FILE)
	$(call DOWNLOAD,$(MDADM_SITE),$(MDADM_SOURCE))
	touch -c $@

$(MDADM_DIR)/.unpacked: $(DL_DIR)/$(MDADM_SOURCE)
	$(MDADM_CAT) $(DL_DIR)/$(MDADM_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
ifneq ($(MDADM_PATCH),)
	(cd $(MDADM_DIR) && $(MDADM_CAT) $(MDADM_PATCH_FILE) | patch -p1)
	if [ -d $(MDADM_DIR)/debian/patches ]; then \
	  toolchain/patch-kernel.sh $(MDADM_DIR) $(MDADM_DIR)/debian/patches \*patch; \
	fi
endif
	#toolchain/patch-kernel.sh $(MDADM_DIR) package/mdadm #mdadm-$(MDADM_VERSION)\*.patch
	#toolchain/patch-kernel.sh $(MDADM_DIR) package/mdadm mdadm-\*.patch
	cat patches/mdadm-3.1.1.patch | patch -p0 -d $(MDADM_DIR)
	touch $@

$(MDADM_DIR)/$(MDADM_BINARY): $(MDADM_DIR)/.unpacked
	$(MAKE) CFLAGS="$(TARGET_CFLAGS) -DUCLIBC -DHAVE_STDINT_H" CC=$(TARGET_CC) -C $(MDADM_DIR)

$(TARGET_DIR)/$(MDADM_TARGET_BINARY): $(MDADM_DIR)/$(MDADM_BINARY)
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(MDADM_DIR) install
	rm -Rf $(TARGET_DIR)/usr/share/man
	$(STRIPCMD) $(STRIP_STRIP_ALL) $@

mdadm-source: $(DL_DIR)/$(MDADM_SOURCE) $(MDADM_PATCH_FILE)

mdadm-unpacked: $(MDADM_DIR)/.unpacked

mdadm: uclibc $(TARGET_DIR)/$(MDADM_TARGET_BINARY)

mdadm-clean:
	$(MAKE) DESTDIR=$(TARGET_DIR) -C $(MDADM_DIR) uninstall
	-$(MAKE) -C $(MDADM_DIR) clean

mdadm-dirclean:
	rm -rf $(MDADM_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_MDADM),y)
TARGETS+=mdadm
endif
