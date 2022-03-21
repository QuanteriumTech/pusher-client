#import <Foundation/Foundation.h>
#import <libPusher/PTPusher.h>
#import <libPusher/PTPusherChannel.h>
#import <libPusher/PTPusherEvent.h>
#import <libPusher/PTPusherEventDispatcher.h>
#import <libPusher/PTPusherChannelServerBasedAuthorization.h>

extern void receiveMsg(char* msg);
void startPusher(char * pusherKey, char * authEndpoint, char * channelName, char * userAuth);

@interface PTPusher (PTPusher)
	@property NSString *userAuth;
 	- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation;
@end
