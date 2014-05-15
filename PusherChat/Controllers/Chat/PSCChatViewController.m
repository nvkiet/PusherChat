//
//  PSCChatViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChatViewController.h"
#import "PSCAppDelegate.h"

NSString *const kEventNameNewMessage = @"client-chat";

@interface PSCChatViewController ()<PTPusherPresenceChannelDelegate>
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
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_regular.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem  = backButton;
    
    self.navigationItem.title = self.userChat[@"profile"][@"name"];
    
    self.pusherClient = [PSCAppDelegate shareDelegate].pusherClient;
    
    // Configure the auth URL for private/presence channels
    self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://192.168.2.29:5000/pusher/auth"];
    
    self.currentUser = [PFUser currentUser];
    
    [self subscribeToPresenceChannel];
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

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendMessage:(id)sender
{
    if (self.sendMessageTextField.text.length > 0){
        
        // Only trigger a client event once a subscription has been successfully registered with Pusher
        [self.currentChannel triggerEventNamed:kEventNameNewMessage data:@{@"text": self.sendMessageTextField.text}];
        
        self.receiveMessageLabel.text = self.sendMessageTextField.text;
        
        // Create our Installation query
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
        
        // Send push notification to query
        [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:self.sendMessageTextField.text];
        
        self.sendMessageTextField.text = @"";
    }
}

- (void)subscribeToPresenceChannel
{
    // Generate a unique channel
    NSString *channelName = [self generateUniqueChannelName];
    
    // Check If client subcribed
    PTPusherChannel *presenceChannel = [self.pusherClient channelNamed:[NSString stringWithFormat:@"presence-%@", channelName]];
    if (!presenceChannel) {
        
        self.currentChannel = [self.pusherClient subscribeToPresenceChannelNamed:channelName delegate:self];
        
        [self.currentChannel bindToEventNamed:kEventNameNewMessage handleWithBlock:^(PTPusherEvent *channelEvent){
            // channelEvent.data is a NSDictianary of the JSON object received
            NSString *message = [channelEvent.data objectForKey:@"text"];
            
            self.receiveMessageLabel.text = message;
            
            // TODOME: If User is not in chat screen ---> Show notifications to Tab "Messages"
        }];
    }
}

- (NSString *)generateUniqueChannelName
{
    NSString *channelName = nil;
    if ([self.currentUser.objectId compare:self.userChat.objectId options:NSCaseInsensitiveSearch] == NSOrderedAscending){
        channelName = [NSString stringWithFormat:@"%@-%@", self.currentUser.objectId, self.userChat.objectId];
    }
    else{
        channelName = [NSString stringWithFormat:@"%@-%@", self.userChat.objectId, self.currentUser.objectId];
    }
    
    return channelName;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
