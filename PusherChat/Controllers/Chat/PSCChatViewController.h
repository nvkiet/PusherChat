//
//  PSCChatViewController.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSCChatViewController;

@protocol PSCChatVCDelegate <NSObject>

- (void)chatViewControllerRefreshData:(PSCChatViewController *)chatVC;

@end

@interface PSCChatViewController : UIViewController

@property (nonatomic, strong) PFUser *userChat;
@property (nonatomic, weak) id<PSCChatVCDelegate>delegate;

- (void)subscribeToPresenceChannel;

@end


