#import "main.h"

@implementation PTPusher (PTPusher)
 - (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation {
	 [operation.mutableURLRequest setValue:pusher.userAuth forHTTPHeaderField:@"Authorization"];
	 NSLog(@"mutating auth");
}
@end

void startPusher(char * pusherKey, char * authEndpoint, char * channelName, char * userAuth) {
	NSString * key =  [NSString stringWithUTF8String:pusherKey];
	NSString * chan =  [NSString stringWithUTF8String:channelName];

	PTPusher * pusher = [PTPusher pusherWithKey:key delegate:pusher encrypted:YES cluster:@"eu"];
	pusher.authorizationURL = [NSURL URLWithString:[NSString stringWithUTF8String:authEndpoint]];
	pusher.userAuth = [NSString stringWithUTF8String:userAuth];
	
	PTPusherChannel *channel = [pusher subscribeToChannelNamed:chan];

	PTPusherEventBinding * bind = [channel bindToEventNamed:@"my-event" handleWithBlock:^(PTPusherEvent *channelEvent) {
		NSError *error = nil;
		NSData* jsonData = [NSJSONSerialization dataWithJSONObject:channelEvent.data options:NSJSONWritingPrettyPrinted error:&error];
		NSString * newStr =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
		const char *cstr = [newStr UTF8String];
		receiveMsg(cstr);
	}];

	[pusher connect];
	
	NSRunLoop *theRL = [NSRunLoop currentRunLoop];
	[theRL run];
}
