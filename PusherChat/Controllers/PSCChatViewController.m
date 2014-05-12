//
//  PSCChatViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChatViewController.h"

@interface PSCChatViewController ()<PTPusherDelegate>
@property (nonatomic, strong) PTPusher *client;
@end

@implementation PSCChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // self.client is a strong instance variable of class PTPusher
    self.client = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
    
    // subscribe to channel and bind to event
    PTPusherChannel *channel = [self.client subscribeToChannelNamed:@"chat"];
    [channel bindToEventNamed:@"new-message" handleWithBlock:^(PTPusherEvent *channelEvent) {
        // channelEvent.data is a NSDictianary of the JSON object received
        NSString *message = [channelEvent.data objectForKey:@"text"];
        NSLog(@"message received: %@", message);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
