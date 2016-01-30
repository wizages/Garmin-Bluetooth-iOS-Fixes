#import "Headers.h"


CPDistributedMessagingCenter *messageCenter;

%hook GCMMusicController

- (void) didReceiveCommand:(unsigned char) arg1 {
	if (arg1 == 0){
        MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
    }
    else if (arg1 == 1)
    {
        MRMediaRemoteSendCommand(kMRNextTrack, nil);
    }
    else if (arg1 == 2)
    {
        MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
    }
    else if (arg1 == 3)
    {
        [messageCenter sendMessageName:@"volumeUp" userInfo:nil];
    }
    else if (arg1 == 4)
    {
        [messageCenter sendMessageName:@"volumeDown" userInfo:nil];
    }
	%log;
	//%orig;
}
%end

%ctor {
    messageCenter = [CPDistributedMessagingCenter centerNamed:@"com.garmin.connect.mobile"];
    rocketbootstrap_distributedmessagingcenter_apply(messageCenter);
}