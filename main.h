#import <Foundation/Foundation.h>
#import <PTPusher.h>
#import <PTPusherChannel.h>
#import <PTPusherEvent.h>
#import <PTPusherEventDispatcher.h>
#import <PTPusherChannelServerBasedAuthorization.h>

extern void receiveMsg(char* msg);
void startPusher(char * pusherKey, char * authEndpoint, char * channelName, char * userAuth);

@interface PTPusher (PTPusher)
	@property NSString *userAuth;
 	- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation;
@end
