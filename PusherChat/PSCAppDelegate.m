//
//  PSCAppDelegate.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "PSCChatViewController.h"
#import "PSCSplashViewController.h"
#import "PSCLoginViewController.h"
#import "PSCMessagesViewController.h"
#import "PSCContactsViewController.h"
#import "PSCMoreViewController.h"

@interface PSCAppDelegate()<PTPusherDelegate>
@property (nonatomic, strong) PSCSplashViewController *splashVC;
@property (nonatomic, strong) PSCMessagesViewController *messagesVC;
@property (nonatomic, strong) PSCContactsViewController *contactsVC;
@property (nonatomic, strong) PSCMoreViewController *moreVC;
@end

@implementation PSCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Register to use Parse Server
    [Parse setApplicationId:@"lpChB2mmgIXvXoxLDK659ZldptkaUfKMdiH2XBBv"
                  clientKey:@"eTHM0k7l409cgJYWDeeyhMgB0gNd285SiPHnDGtk"];
    
    // Track statistics around application opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];

    // Init Pusher client
    self.pusherClient = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
    
    // Configure the auth URL for private/presence channels
    self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://192.168.2.6:5000/pusher/auth"]; // http://192.168.1.109:5000/pusher/auth
    
    [self.pusherClient connect];
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    [self setupAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.splashVC = [[PSCSplashViewController alloc] initWithNibName:NSStringFromClass([PSCSplashViewController class]) bundle:nil];
    
    self.navController = [[UINavigationController alloc] initWithRootViewController:self.splashVC];
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEventNotification:) name:PTPusherEventReceivedNotification object:self.pusherClient];
    
    // Remove badge value on App's icon
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.isChatScreenVisible = NO;
    
    return YES;
}

+ (PSCAppDelegate *)shareDelegate
{
    return (PSCAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)showLoginScreen
{
    [self.splashVC presentViewController:[[PSCLoginViewController alloc] initWithNibName:NSStringFromClass([PSCLoginViewController class]) bundle:nil]  animated:YES completion:nil];
}

- (void)showHomeScreen
{
    self.tabbarController = [[UITabBarController alloc] init];
    self.tabbarController.delegate = self;
    
    self.messagesVC = [[PSCMessagesViewController alloc] initWithNibName:NSStringFromClass([PSCMessagesViewController class]) bundle:nil];
    UINavigationController *messagesNC =  [[UINavigationController alloc] initWithRootViewController:self.messagesVC];
    
    self.contactsVC = [[PSCContactsViewController alloc] initWithNibName:NSStringFromClass([PSCContactsViewController class]) bundle:nil];
    UINavigationController *contactsNC =  [[UINavigationController alloc] initWithRootViewController:self.contactsVC];
    
    self.moreVC = [[PSCMoreViewController alloc] initWithNibName:NSStringFromClass([PSCMoreViewController class]) bundle:nil];
    UINavigationController *moreNC =  [[UINavigationController alloc] initWithRootViewController:self.moreVC];
    
    self.tabbarController.viewControllers = @ [ messagesNC, contactsNC, moreNC];
    
    self.messagesVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Messages" image:[UIImage imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_messages_idle.png"] selectedImage:[UIImage imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_messages_selected.png"]];
    
    self.contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts" image:[UIImage imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_contacts_idle.png"] selectedImage:[UIImage imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_contacts_selected.png"]];

    self.moreVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"More" image:[UIImage
        imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_more_idle.png"] selectedImage:[UIImage
        imageRenderingModeAlwaysOrigininalWithName:@"tab_icon_more_selected.png"]];
    
    [self.splashVC presentViewController: self.tabbarController animated:NO completion:nil];
}

#pragma mark - Methods

- (void)didReceiveEventNotification:(NSNotification *)notification
{
    PTPusherEvent *channelEvent = [notification.userInfo objectForKey:PTPusherEventUserInfoKey];

    NSLog(@"[pusher] Event name: %@ Channel name: %@ Event data: %@]", channelEvent.name, channelEvent.channel, channelEvent.data);
}

- (void)addBadgeValueToMessagesTab: (NSString *)badgeValue
{
    self.messagesVC.tabBarItem.badgeValue = badgeValue;
}

- (void)setupAppearance
{
    // Set Tabbar Text Color
    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateSelected];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor navBGKColor]];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName: FONT_HELVETICAL_REGULAR size:17.0f]}];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor]} forState: UIControlStateNormal];
    
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}

#pragma  mark - Notificaitons

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
}

// Parse will create a modal alert and display the push notification's content.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *message = userInfo[@"aps"][@"alert"];
    NSString *userId = userInfo[@"UserId"];
    
    // FIXME: Repeat code
    // Generate a unique channel
    NSString *channelName = [self generateUniqueChannelNameWithUserId:[PFUser currentUser].objectId andUserId:userId];
    self.currentChannel = [self.pusherClient subscribeToPresenceChannelNamed:channelName delegate:nil];
    
    [self.currentChannel bindToEventNamed:kEventNameNewMessage handleWithBlock:^(PTPusherEvent *channelEvent){
        NSString *message = [channelEvent.data objectForKey:kMessageContentKey];
        
        [self.messagesVC refreshData];
        
        [self addBadgeValueToMessagesTab:message];
    }];
    
    [self.messagesVC refreshData];
    
    [self addBadgeValueToMessagesTab:message];
    
    NSLog(@"[parse] Messsage: %@  UserId: %@", message, userId);
}

#pragma mark - Methods

- (NSString *)generateUniqueChannelNameWithUserId:(NSString*)userId_A andUserId:(NSString *)userId_B
{
    NSString *channelName = nil;
    if ([userId_A compare:userId_B options:NSCaseInsensitiveSearch] == NSOrderedAscending){
        channelName = [NSString stringWithFormat:@"%@-%@", userId_A, userId_B];
    }
    else{
        channelName = [NSString stringWithFormat:@"%@-%@", userId_B, userId_A];
    }
    
    return channelName;
}

#pragma mark - Reachability

- (void)startReachabilityCheck
{
    // we probably have no internet connection, so lets check with Reachability
    Reachability *reachability = [Reachability reachabilityWithHostname:self.pusherClient.connection.URL.host];
    
    if ([reachability isReachable]) {
        // we appear to have a connection, so something else must have gone wrong
        NSLog(@"Internet reachable, reconnecting");
        [_pusherClient connect];
    }
    else {
        NSLog(@"Waiting for reachability");
        
        [reachability setReachableBlock:^(Reachability *reachability) {
            if ([reachability isReachable]) {
                NSLog(@"Internet is now reachable");
                [reachability stopNotifier];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pusherClient connect];
                });
            }
        }];
        
        [reachability startNotifier];
    }
}

- (void)logOut
{
    [PFUser logOut];
    
    self.messagesVC = nil;
    self.contactsVC = nil;
    self.moreVC = nil;
}


#pragma mark - PTPusherDelegate

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher] Pusher client connecting...");
    return YES;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"[pusher-%@] Pusher client connected", connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
    NSLog(@"[pusher] Pusher Connection failed with error: %@", error);
    if ([error.domain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {
        [self startReachabilityCheck];
    }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
    NSLog(@"[pusher-%@] Pusher Connection disconnected with error: %@", pusher.connection.socketID, error);
    
    if (willAttemptReconnect) {
        NSLog(@"[pusher-%@] Client will attempt to reconnect automatically", pusher.connection.socketID);
    }
    else {
        if (![error.domain isEqualToString:PTPusherErrorDomain]) {
            [self startReachabilityCheck];
        }
    }
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
    NSLog(@"[pusher-%@] Client automatically reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
    return YES;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"[pusher-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
    NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:[NSString stringWithFormat:@"Client with socket ID %@ could not be authorized to join channel %@", pusher.connection.socketID, channel.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
    NSLog(@"[pusher-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

/*
 This demonstrates how we can intercept the authorization request to configure it for our app's
 authentication/authorisation needs.
*/
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
    NSLog(@"[pusher-%@] Authorizing channel access...", pusher.connection.socketID);
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",[[PSCUserManager sharedInstance] getAccessToken]] forHTTPHeaderField:@"Authorization"];
}

// App switching methods to support Facebook Single Sign-On.
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
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
    if (self.pusherClient) {
        [self.currentChannel unsubscribe];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppWillEnterForeground object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
    [[PFFacebookUtils session] close];
}

@end
