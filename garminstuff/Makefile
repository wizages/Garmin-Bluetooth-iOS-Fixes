include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Garminstuff
Garminstuff_FILES = Tweak.xm
Garminstuff_PRIVATE_FRAMEWORKS = MediaRemote

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 ConnectMobile"
