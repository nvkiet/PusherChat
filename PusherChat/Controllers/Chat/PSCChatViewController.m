//
//  PSCChatViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChatViewController.h"
#import "PSCAppDelegate.h"
#import "PSCBubbleCell.h"
#import "PSCBubbleData.h"

NSString *const kEventNameNewMessage = @"client-chat";

@interface PSCChatViewController ()<PTPusherPresenceChannelDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) PTPusher *pusherClient;
@property (nonatomic, strong) PTPusherPresenceChannel *currentChannel;

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UIImageView *textInputImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@property (nonatomic, strong) NSMutableArray * bubblesdataArray;
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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_regular.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem  = backButton;
    
    self.navigationItem.title = self.userChat[@"profile"][@"name"];
    
    self.pusherClient = [PSCAppDelegate shareDelegate].pusherClient;
    
    // Configure the auth URL for private/presence channels
    self.pusherClient.authorizationURL = [NSURL URLWithString:@"http://192.168.1.109:5000/pusher/auth"];
    
    self.currentUser = [PFUser currentUser];
    
    [self subscribeToPresenceChannel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textInputImageView setImage:[UIImage imageNamed:@"text_input_view_bkg.png"]];
    
    // Set up Bubble table view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];

    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.bubblesdataArray = [[NSMutableArray alloc] init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bubblesdataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PSCBubbleCell";
    
    PSCBubbleCell *cell = (PSCBubbleCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PSCBubbleCell alloc] init];
    }
    
    PSCBubbleData *bubbleData = [self.bubblesdataArray objectAtIndex:indexPath.row];
    [cell configureDataWithModel:bubbleData];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSCBubbleData *bubbleData = [self.bubblesdataArray objectAtIndex:indexPath.row];
    return MAX(bubbleData.insets.top + bubbleData.view.frame.size.height + bubbleData.insets.bottom, 0);
}

#pragma mark - Keyboard events

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSValue *value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = self.textInputView.frame;
        frame.origin.y -= kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.tableView.frame;
        frame.size.height -= kbSize.height;
        self.tableView.frame = frame;
    }];
    
    [self scrollBubbleViewToBottomAnimated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        CGRect frame = self.textInputView.frame;
        frame.origin.y += kbSize.height;
        self.textInputView.frame = frame;
        
        frame = self.tableView.frame;
        frame.size.height += kbSize.height;
        self.tableView.frame = frame;
    }];
}


#pragma mark - didTapOnTableView

- (void)didTapOnTableView:(id)sender
{
    [self.messageTextField resignFirstResponder];
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

- (void)textFieldDidChange:(id)sender
{
    if (self.messageTextField.text.length > 0) {
        [self.sendButton setTitleColor:[UIColor navBGKColor] forState:UIControlStateNormal];
    }
    else{
        [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendMessage:(id)sender
{
    if (self.messageTextField.text.length > 0){
        
        [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        // Only trigger a client event once a subscription has been successfully registered with Pusher
        [self.currentChannel triggerEventNamed:kEventNameNewMessage data:@{@"text": self.messageTextField.text}];
        
        PSCBubbleData *bubbleData = [[PSCBubbleData alloc] initWithText:self.messageTextField.text type:BubbleTypeMine];
        [self addNewRowWithBubbleData:bubbleData];
        
        self.messageTextField.text = @"";
    }
}

#pragma mark - Methods

- (void)addNewRowWithBubbleData:(PSCBubbleData *)bubbleData
{
    [self.bubblesdataArray addObject:bubbleData];
    
    NSArray *insertIndexPaths = @[[NSIndexPath indexPathForRow:self.bubblesdataArray.count - 1 inSection:0]];
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    // Scroll to bottom
    [self scrollBubbleViewToBottomAnimated:YES];
}

- (void)subscribeToPresenceChannel
{
    // Generate a unique channel
    NSString *channelName = [self generateUniqueChannelName];
    
//    // Check If client subcribed
//    PTPusherChannel *presenceChannel = [self.pusherClient channelNamed:[NSString stringWithFormat:@"presence-%@", channelName]];
//    if (!presenceChannel) {
//        
//    }
    self.currentChannel = [self.pusherClient subscribeToPresenceChannelNamed:channelName delegate:self];
    
    [self.currentChannel bindToEventNamed:kEventNameNewMessage handleWithBlock:^(PTPusherEvent *channelEvent){
        // channelEvent.data is a NSDictianary of the JSON object received
        NSString *message = [channelEvent.data objectForKey:@"text"];
        
        PSCBubbleData *bubbleData = [[PSCBubbleData alloc] initWithText:message type:BubbleTypeSomeoneElse];
        [self addNewRowWithBubbleData:bubbleData];
        
        // TODOME: If User is not in chat screen ---> Show notifications to Tab "Messages"
    }];
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

- (void)scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastRowIdx = self.bubblesdataArray.count - 1;
    
    if (lastRowIdx >= 0)
    {
    	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIdx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
