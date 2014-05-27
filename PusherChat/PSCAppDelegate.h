//
//  PSCAppDelegate.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabbarController;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) PTPusher *pusherClient;
@property (nonatomic) BOOL isChatScreenVisible;


+ (PSCAppDelegate *)shareDelegate;

- (void)showLoginScreen;
- (void)showHomeScreen;
- (void)logOut;

- (void)addBadgeValueToMessagesTab: (NSString *)badgeValue;
- (void)removeBadgeValueToMessagesTab;

- (NSString *)generateUniqueChannelNameWithUserId:(NSString*)userId_A andUserId:(NSString *)userId_B;

@end
