//
//  PSCAppDelegate.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) PTPusher *pusherClient;

+ (PSCAppDelegate *)shareDelegate;

- (void)showLoginScreen;
- (void)showHomeScreen;

@end
