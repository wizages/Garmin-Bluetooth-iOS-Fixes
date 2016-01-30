#import "Headers.h"

static id observer;
BBServer *bbServer;
CPDistributedMessagingCenter *messageCenter;

%hook BBServer
    - (id)init {
        bbServer = %orig;
        return bbServer;
    }
%end

%hook SBUIController

+ (SBUIController *)sharedInstance {
    SBUIController *sharedInstance = %orig;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        messageCenter = [CPDistributedMessagingCenter centerNamed:@"com.garmin.connect.mobile"];
        rocketbootstrap_distributedmessagingcenter_apply(messageCenter);
        [messageCenter runServerOnCurrentThread];
        [messageCenter registerForMessageName:@"volumeUp" target:sharedInstance selector:@selector(volumeUp)];
        [messageCenter registerForMessageName:@"volumeDown" target:sharedInstance selector:@selector(volumeDown)];
        });
    return sharedInstance;
}

%new
- (void)volumeDown {
    VolumeControl *vc = [%c(VolumeControl) sharedVolumeControl];
    [vc decreaseVolume];
    [vc cancelVolumeEvent];
}

%new
- (void)volumeUp {
    VolumeControl *vc = [%c(VolumeControl) sharedVolumeControl];
    [vc increaseVolume];
    [vc cancelVolumeEvent];
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
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



