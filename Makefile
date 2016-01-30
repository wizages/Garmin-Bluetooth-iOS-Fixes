include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GarminConnectFixes
GarminConnectFixes_FILES = Tweak.xm
GarminConnectFixes_PRIVATE_FRAMEWORKS =AudioToolbox BulletinBoard AppSupport
GarminConnectFixes_LIBRARIES = rocketbootstrap
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += garminstuff
SUBPROJECTS += deviceio
include $(THEOS_MAKE_PATH)/aggregate.mk
