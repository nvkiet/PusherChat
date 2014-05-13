//
//  PSCChatViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChatViewController.h"
#import "PSCAppDelegate.h"

@interface PSCChatViewController ()<PTPusherDelegate, PTPusherPresenceChannelDelegate>

@property (nonatomic, strong) PTPusher *pusherClient;
@property (nonatomic, strong) PTPusherPresenceChannel *currentChannel;

@property (weak, nonatomic) IBOutlet UILabel *receiveMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;
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
    
    PSCAppDelegate *appDelegate = (PSCAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.pusherClient = appDelegate.pusherClient;
    
    // Configure the auth URL for private/presence channels
    self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://localhost:9292/presence/auth"];
    
    [self subscribeToPresenceChannel:@"demo"];
}

#pragma mark - Presence channel events

- (void)presenceChannelDidSubscribe:(PTPusherPresenceChannel *)channel
{
    NSLog(@"[pusher] Channel members: %@", channel.members);
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(PTPusherChannelMember *)member
{
    NSLog(@"[pusher] Member joined channel: %@", member);
}

- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(PTPusherChannelMember *)member
{
    NSLog(@"[pusher] Member left channel: %@", member);
}

#pragma mark - Actions

- (IBAction)btnSendMessage:(id)sender
{
    if (self.sendMessageTextField.text.length > 0) {
        [self.currentChannel triggerEventNamed:@"new-message" data:@{@"text": self.sendMessageTextField.text}];
    }
}

- (void)subscribeToPresenceChannel:(NSString *)channelName
{
    self.currentChannel = [self.pusherClient subscribeToPresenceChannelNamed:channelName delegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
