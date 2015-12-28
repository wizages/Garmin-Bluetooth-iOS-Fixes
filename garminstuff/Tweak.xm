#import "MediaRemote.h"
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
	%log;
	//%orig;
}



%end