#import <Springboard/SBApplicationController.h>
#import <SpringBoard/SpringBoard.h>


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


static id observer;
%ctor {
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
        object:nil queue:[NSOperationQueue mainQueue]
        usingBlock:^(NSNotification *notification) {
            [(SpringBoard *)[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.garmin.connect.mobile" suspended:YES];
        }];
}

