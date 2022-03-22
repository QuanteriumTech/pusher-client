#import "main.h"
#import <objc/runtime.h>

@implementation PTPusher (PTPusher) 
	NSString const *key = @"my.very.unique.key";
	- (void)setUserAuth:(NSString *)userAuth
	{
    	objc_setAssociatedObject(self, &key, userAuth, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	- (NSString *) userAuth {
		return objc_getAssociatedObject(self, &key);
	}
@end

@implementation PusherDelegate

#pragma mark - PTPusherEventDelegate methods

- (void)pusher:(PTPusher *)pusher willAuthorizeChannel:(PTPusherChannel *)channel withAuthOperation:(PTPusherChannelAuthorizationOperation *)operation {
	NSLog(@"mutating auth");
	[operation.mutableURLRequest setValue:pusher.userAuth forHTTPHeaderField:@"Authorization"];
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"Connected!");
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection
{
    NSLog(@"Disconnected!");
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    NSLog(@"Connection Failed! %@", error);
}

@end

void startPusher(char * pusherKey, char * authEndpoint, char * channelName, char * userAuth) {
	NSString * key =  [NSString stringWithUTF8String:pusherKey];
	NSString * chan =  [NSString stringWithUTF8String:channelName];
	PusherDelegate * del = [[PusherDelegate alloc]init];

	PTPusher * pusher = [PTPusher pusherWithKey:key delegate:del encrypted:YES cluster:@"eu"];
	pusher.authorizationURL = [NSURL URLWithString:[NSString stringWithUTF8String:authEndpoint]];
	NSLog(@"pusher authURL: %@", pusher.authorizationURL);
	pusher.userAuth = [NSString stringWithUTF8String:userAuth];
	NSLog(@"pusher userAuth: %@", pusher.userAuth);
	
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
