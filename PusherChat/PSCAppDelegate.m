//
//  PSCAppDelegate.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "PSCChatViewController.h"

@interface PSCAppDelegate()<PTPusherDelegate>
@end

@implementation PSCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.client = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
    
    // Subscribe to channel and bind to event
    PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"chat"];
    [channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSString *message = [channelEvent.data objectForKey:@"text"];
        NSLog(@"message received: %@", message);
    }];
    
    [self.client connect];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    PSCChatViewController *chatViewController = [[PSCChatViewController alloc] initWithNibName:NSStringFromClass([PSCChatViewController class]) bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:chatViewController];
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
       
    return YES;
}

#pragma mark - PTPusherDelegate

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"Has connected to the Pusher service successfully!");
}

// Handling disconnections
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
