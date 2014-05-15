//
//  PSCChatViewController.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSCChatViewController : UIViewController

@property (nonatomic, strong) PFUser *userChat;
@property (nonatomic, strong) PFUser *currentUser;

- (void)subscribeToPresenceChannel;

@end
