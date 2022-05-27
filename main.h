#import <Foundation/Foundation.h>
#import <PTPusher.h>
#import <PTPusherChannel.h>
#import <PTPusherEvent.h>
#import <PTPusherEventDispatcher.h>
#import <PTPusherChannelServerBasedAuthorization.h>

extern void receiveMsg(char* msg);
extern void updateStatus(char* msg);

void startPusher(char * pusherKey);
void subscribeToChannel(char * channelName, char * userAuth, char * authEndpoint);
void unsubscribeFromChannel();

@interface PTPusher (PTPusher)
	@property (strong, nonatomic) NSString *userAuth;
	@property (strong, nonatomic) NSString *channelName;
@end

@interface PusherDelegate : NSObject <PTPusherDelegate>
@end