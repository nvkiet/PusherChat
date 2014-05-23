//
//  PSCChatViewController.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSCChatViewController;

@interface PSCChatViewController : UIViewController

@property (nonatomic, strong) PFUser *userChat;

- (void)subscribeToPresenceChannel;

@end


