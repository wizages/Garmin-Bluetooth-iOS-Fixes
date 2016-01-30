#import "MediaRemote.h"
#import <rocketbootstrap/rocketbootstrap.h>
@interface CPDistributedMessagingCenter : NSObject
+(CPDistributedMessagingCenter*)centerNamed:(NSString*)serverName;
-(BOOL)sendMessageName:(NSString*)name userInfo:(NSDictionary*)info;
@end