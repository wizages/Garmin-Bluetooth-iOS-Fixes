include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GarminConnectMusicFix
GarminConnectMusicFix_FILES = Tweak.xm
GarminConnectMusicFix_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += garminstuff
include $(THEOS_MAKE_PATH)/aggregate.mk
