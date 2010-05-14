#############################################################
#
# lame
#
#############################################################
LAME_VERSION = 3.98.4
LAME_SOURCE = lame-$(LAME_VERSION).tar.gz
LAME_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/lame/
LAME_AUTORECONF = NO
LAME_INSTALL_STAGING = YES
LAME_INSTALL_TARGET = YES

LAME_DEPENDENCIES = uclibc

$(eval $(call AUTOTARGETS,package/multimedia,lame))

#$(LAME_HOOK_POST_INSTALL):
#	rm -f $(TARGET_DIR)/usr/share/aclocal/ogg.m4
#	touch $@
