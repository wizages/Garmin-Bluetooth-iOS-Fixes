include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Garminstuff
Garminstuff_FILES = Tweak.xm
Garminstuff_PRIVATE_FRAMEWORKS = MediaRemote AppSupport
Garminstuff_LIBRARIES = rocketbootstrap
Garminstuff_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 ConnectMobile"
