#import <Springboard/SBApplicationController.h>
#import <SpringBoard/SpringBoard.h>
#import <Springboard/SBBulletinBannerController.h>
#import <AudioToolbox/AudioToolbox.h>
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
-(void)connection:(id)connection didReceiveIncomingMessage:(id)message;
@end


static id observer;
BBServer *bbServer;

%hook BBServer
    - (id)init {
        bbServer = %orig;
        return bbServer;
    }
    - (void)publishBulletin:(BBBulletin*)bulletin destinations:(int)dests alwaysToLockScreen:(BOOL)lock{
        %log;
        %orig;
    }
%end

%ctor {
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
        object:nil queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {
            int64_t delay = 5.0; // In seconds
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
            HBLogDebug(@"Launched?");
            SBCCBluetoothSetting *bluetooth = [%c(SBCCBluetoothSetting) new];
            [bluetooth _updateState];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 15 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                HBLogDebug(@"Cycle BT")
                
                
                
                [bluetooth _toggleState];
                [bluetooth release];
                
                
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                HBLogDebug(@"Done pushing notification")
                /*
                NSDictionary *userInfo = @{ @"aps" : @{ @"badge" : @5, @"alert" : @"hi" } };
                NSString *topic = @"com.garmin.connect.mobile";
                APSIncomingMessage *message = [[%c(APSIncomingMessage) alloc] initWithTopic:topic userInfo:userInfo];
                [[%c(SBRemoteNotificationServer) sharedInstance] connection:nil didReceiveIncomingMessage:message];
                [message release];
                */
                BBBulletin *bulletin = [[BBBulletin alloc] init];  
                bulletin.sectionID =  @"com.garmin.connect.mobile";  
                bulletin.title =  @"Garmin Watch";  
                bulletin.message  = @"Your Garmin watch is fully connected";
                bulletin.clearable = YES;
                bulletin.bulletinID = @"GarminWatch";
                bulletin.date = [NSDate date];
                bulletin.publicationDate = [NSDate date];
                bulletin.lastInterruptDate = [NSDate date];
                SystemSoundID lowSound;
                AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:lowsound isDirectory:NO],&lowSound);
                if(lowSound) bulletin.sound=[BBSound alertSoundWithSystemSoundID:lowSound];
                if (bbServer)
                    [bbServer publishBulletin:bulletin destinations:14 alwaysToLockScreen:NO];
                /*
                SystemSoundID beep;
                AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:alertsnd isDirectory:NO],&beep);
                if(beep) bulletin.sound=[BBSound alertSoundWithSystemSoundID:beep];
                beep=NULL;
                */
                //BBDataProviderAddBulletin(self,bulletin);
                
                
            });
            dispatch_after(time, dispatch_get_main_queue(), ^(void){
                
                HBLogDebug(@"Delayed");
                [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.garmin.connect.mobile" suspended:YES];
                [bluetooth _toggleState];
                /*BBBulletin *bulletin = [[BBBulletin alloc] init];
                bulletin.bulletinID = @"com.garmin.connect.mobile";
                bulletin.sectionID = @"com.garmin.connect.mobile";
                //warning: class method '+actionWithLaunchBundleID:' not found (return type defaults to 'id') [-Wobjc-method-access]
                //still works fine though
                bulletin.defaultAction = [BBAction actionWithLaunchBundleID:bulletin.sectionID];
                bulletin.title = @"Garmin Connect";
                bulletin.message = @"Garmin Connect has successfully started";
                [(SBBulletinBannerController *)[%c(SBBulletinBannerController) sharedInstance] observer:nil addBulletin:bulletin forFeed:2];
                [bulletin release];
                */
        // Or put the code from doSomethingLater: inline here
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                HBLogDebug(@"Boot app");
                SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.garmin.connect.mobile"];

                FBScene *scene = [application mainScene];
                if (!scene || !scene.settings || !scene.mutableSettings) {
                    return;
                }

                FBSMutableSceneSettings *sceneSettings = scene.mutableSettings;
                sceneSettings.backgrounded = YES;
                [scene _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];
                [bluetooth _toggleState];
                
            });
            }
        ];
    
}

