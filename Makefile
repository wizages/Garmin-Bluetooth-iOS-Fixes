include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GarminConnectFixes
GarminConnectFixes_FILES = Tweak.xm
GarminConnectFixes_PRIVATE_FRAMEWORKS =AudioToolbox BulletinBoard
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += garminstuff
include $(THEOS_MAKE_PATH)/aggregate.mk
