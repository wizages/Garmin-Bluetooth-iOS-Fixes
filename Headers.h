#import <Springboard/SBApplicationController.h>
#import <SpringBoard/SpringBoard.h>
#import <Springboard/SBBulletinBannerController.h>
#import <AudioToolbox/AudioToolbox.h>
#import <rocketbootstrap/rocketbootstrap.h>
#define lowsound @"/System/Library/Audio/UISounds/low_power.caf"

@interface BBSound
+ (id)alertSoundWithSystemSoundID:(unsigned long)arg1;
@end

@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *sectionID; // @dynamic sectionID;
@property(copy, nonatomic) NSString *title; // @dynamic title;
@property(copy, nonatomic) NSString *message; // @dynamic title;
@property(copy, nonatomic) BBSound *sound; // @dynamic defaultAction;
@property(retain, nonatomic) NSDate *date;
@property(copy, nonatomic) NSString *bulletinID;
@property(retain, nonatomic) NSDate *publicationDate;
@property(retain, nonatomic) NSDate *lastInterruptDate;
@property(nonatomic) BOOL showsMessagePreview;
@property(nonatomic) BOOL clearable;
@end

@interface BBServer
- (void)_publishBulletinRequest:(id)arg1 forSectionID:(id)arg2 forDestinations:(unsigned int)arg3 alwaysToLockScreen:(BOOL)arg4;
- (void)demo_lockscreen:(unsigned long long)arg1;
- (void)_sendAddBulletin:(id)arg1 toFeeds:(unsigned int)arg2;
- (void)publishBulletin:(BBBulletin*)bulletin destinations:(int)dests alwaysToLockScreen:(BOOL)lock;
@end

@interface SBCCBluetoothSetting : NSObject
- (void)_updateState;
- (void)_toggleState;
@end

@interface FBSSceneSettings : NSObject
@end

@interface FBSMutableSceneSettings : FBSSceneSettings
@property(nonatomic, getter=isBackgrounded) BOOL backgrounded;
@end

@interface FBScene : NSObject
@property(readonly, retain, nonatomic) FBSMutableSceneSettings *mutableSettings;
@property(readonly, retain, nonatomic) FBSSceneSettings *settings;
- (void)_applyMutableSettings:(id)arg1 withTransitionContext:(id)arg2 completion:(id)arg3;
@end

@interface SBApplication
-(void) clearDeactivationSettings;
-(FBScene*) mainScene;
-(id) mainScreenContextHostManager;
-(id) mainSceneID;
- (void)activate;

- (void)processDidLaunch:(id)arg1;
- (void)processWillLaunch:(id)arg1;
- (void)resumeForContentAvailable;
- (void)resumeToQuit;
- (void)_sendDidLaunchNotification:(_Bool)arg1;
- (void)notifyResumeActiveForReason:(long long)arg1;

@end

@interface BBAction : NSObject
+ (BBAction *)actionWithLaunchBundleID:(id)arg1;
@end

@interface APSIncomingMessage :NSObject
- (id)initWithTopic:(id)arg1 userInfo:(NSDictionary *)arg2;
@end

@interface SBRemoteNotificationServer
+(id)sharedInstance;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
@end

@interface VolumeControl
+ (VolumeControl *)sharedVolumeControl;
- (void)decreaseVolume;
- (void)increaseVolume;
- (void)cancelVolumeEvent;
@end

@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(void)registerForMessageName:(NSString*)messageName target:(id)target selector:(SEL)selector;
-(void)runServerOnCurrentThread;
@end