#import "Headers.h"

static id observer;
BBServer *bbServer;
CPDistributedMessagingCenter *messageCenter;
BOOL needUnlock = false;

static void GarminConnectFixMe(BOOL isUnlock){
            int64_t delay;
            if(!isUnlock)
                delay = 5.0; // In seconds
            else
                delay = 15.0;
            dispatch_time_t timedis = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
            HBLogDebug(@"Launched?");
            SBCCBluetoothSetting *bluetooth = [%c(SBCCBluetoothSetting) new];
            [bluetooth _updateState];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (10 + delay) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                HBLogDebug(@"Cycle BT") 
                if(!isUnlock)
                {
                    [bluetooth _toggleState];
                    HBLogDebug(@"FML")
                }
                [bluetooth release];
                
                
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (25 + delay) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                
                HBLogDebug(@"Done pushing notification")
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
                
            });
            dispatch_after(timedis, dispatch_get_main_queue(), ^(void){
                
                HBLogDebug(@"Delayed");
                [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.garmin.connect.mobile" suspended:YES];
                if(!isUnlock)
                    [bluetooth _toggleState];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (5 + delay) * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                HBLogDebug(@"Boot app");
                SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:@"com.garmin.connect.mobile"];

                FBScene *scene = [application mainScene];
                if (!scene || !scene.settings || !scene.mutableSettings) {
                    return;
                }

                FBSMutableSceneSettings *sceneSettings = scene.mutableSettings;
                sceneSettings.backgrounded = YES;
                [scene _applyMutableSettings:sceneSettings withTransitionContext:nil completion:nil];
                if(!isUnlock)
                    [bluetooth _toggleState];
                
            });
}

%hook BBServer
    - (id)init {
        bbServer = %orig;
        return bbServer;
    }
%end

%hook SBLockScreenViewController
-(void) finishUIUnlockFromSource:(int)source
{
    %orig;
    if(needUnlock){
        GarminConnectFixMe(true);
        needUnlock = false;
    }
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
            double bootTimer;

            struct timeval boottime;
            size_t len = sizeof(boottime);
            int mib[2] = { CTL_KERN, KERN_BOOTTIME };
            if( sysctl(mib, 2, &boottime, &len, NULL, 0) < 0 )
            {
                bootTimer = -1;
            }
            time_t bsec = boottime.tv_sec; 
            time_t csec = time(NULL);
            bootTimer = difftime(csec, bsec);
             
            if(bootTimer > 60){
               GarminConnectFixMe(false);
            }else
            {
                needUnlock = true;
            }
        }];
}



