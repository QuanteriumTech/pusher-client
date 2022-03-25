#import "main.h"
#import <objc/runtime.h>

@implementation PTPusher (PTPusher) 
	NSString const *key = @"my.very.unique.key";
	- (void)setUserAuth:(NSString *)userAuth {
    	objc_setAssociatedObject(self, &key, userAuth, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	- (NSString *) userAuth {
		return objc_getAssociatedObject(self, &key);
	}
@end

@implementation PusherDelegate

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation {
	updateStatus([@"authenticating" UTF8String]);
	[operation.mutableURLRequest setValue:pusher.userAuth forHTTPHeaderField:@"Authorization"];
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection {
	const char *cstr = [@"connected" UTF8String];
	updateStatus(cstr);
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection {
	updateStatus([@"disconnected" UTF8String]);
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error {
	updateStatus([[NSString stringWithFormat:@"connection_failed: %@", error] UTF8String]);
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection {
	updateStatus([@"will_connect" UTF8String]);
	return YES; // NO to abort connection attempt
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect {
	updateStatus([[NSString stringWithFormat:@"disconnected_with_error: %@", error] UTF8String]);
	updateStatus([[NSString stringWithFormat:@"will_reconnect: %@",  willAttemptReconnect ? @"YES" : @"NO"] UTF8String]);
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay {
	updateStatus([[NSString stringWithFormat:@"connection_will_auto_reconnect: %f", delay] UTF8String]);
	return YES; // NO to abort connection attempt
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel {
	updateStatus([[NSString stringWithFormat:@"did_subscribe: %@", channel.name] UTF8String]);
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel {
	updateStatus([[NSString stringWithFormat:@"did_unsubscribe: %@", channel.name] UTF8String]);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error {
	updateStatus([[NSString stringWithFormat:@"did_fail_to_subscribe: %@ - %@", channel.name, error] UTF8String]);
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent {
	updateStatus([[NSString stringWithFormat:@"error: %@", errorEvent] UTF8String]);
}

@end

static PusherDelegate * del = nil;
static PTPusher * pusher = nil;
static PTPusherChannel * channel = nil;
static PTPusherEventBinding * bind = nil;

void startPusher(char * pusherKey, char * authEndpoint) {
	del = [[PusherDelegate alloc] init];
	pusher = [PTPusher pusherWithKey:[NSString stringWithUTF8String:pusherKey] delegate:del encrypted:YES cluster:@"eu"];
	pusher.authorizationURL = [NSURL URLWithString:[NSString stringWithUTF8String:authEndpoint]];
	
	[pusher connect];
	
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	[theRL run];
}

void subscribeToChannel(char * channelName , char * userAuth) {
	pusher.userAuth = [NSString stringWithUTF8String:userAuth];

	channel = [pusher subscribeToChannelNamed:[NSString stringWithUTF8String:channelName]];
	bind = [channel bindToEventNamed:@"my-event" handleWithBlock:^(PTPusherEvent *channelEvent) {
		NSError *error = nil;
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:channelEvent.data options:NSJSONWritingPrettyPrinted error:&error];
		NSString * newStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		const char *cstr = [newStr UTF8String];
		receiveMsg(cstr);
	}];
}

void unsubscribeFromChannel() {
	[channel unsubscribe];
}