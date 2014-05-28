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


@interface PSCChatViewController ()<PTPusherPresenceChannelDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) PTPusherPresenceChannel *currentChannel;

@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UIImageView *textInputImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;


@property (nonatomic, strong) NSMutableArray * bubblesdataArray;
@property (nonatomic) BOOL hasSentMsgg;
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
    
    // Subscribe presence channel
    self.currentUser = [PFUser currentUser];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon_regular.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonClicked:)];
    self.navigationItem.leftBarButtonItem  = backButton;
    
    self.navigationItem.title = self.userChat[@"profile"][@"name"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.textInputImageView setImage:[UIImage imageNamed:@"text_input_view_bkg.png"]];
    
    // Set up Bubble table view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];

    [self.messageTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //  Observer the App's State
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kNotificationAppWillEnterForeground object:nil];
    
    [self refreshData];
    
    // User is in chat screen
    [PSCAppDelegate shareDelegate].isChatScreenVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // User is not in chat screen
    [PSCAppDelegate shareDelegate].isChatScreenVisible = NO;
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
    
    if (indexPath.row >= 0 && indexPath.row < self.bubblesdataArray.count) {
        PSCBubbleData *bubbleData = [self.bubblesdataArray objectAtIndex:indexPath.row];
        [cell configureDataWithModel:bubbleData];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSCBubbleData *bubbleData = [self.bubblesdataArray objectAtIndex:indexPath.row];
    return bubbleData.insets.top + bubbleData.view.frame.size.height + bubbleData.insets.bottom + 10;
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
    if (self.hasSentMsgg) {
        
        PSCBubbleData *lastMessage = [self.bubblesdataArray lastObject];
        NSString *timeCreatedString = [NSDateFormatter stringWithDefaultFormatFromDate:lastMessage.timeCreated];
        
        if (lastMessage) {
            BOOL isSender = (lastMessage.type == BubbleTypeMine ? NO : YES);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewMessageComming
                                                                object:nil
                                                              userInfo:@{kObjectId:self.userChat.objectId,
                                                                         kIsSender:[NSNumber numberWithBool:isSender],
                                                                         kMessageContentKey:lastMessage.content,
                                                                         kMessageTimeCreatedKey:timeCreatedString,
                                                                         kMessageStatusKey:[NSNumber numberWithBool:YES]}];
 
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnSendMessage:(id)sender
{
    if (self.messageTextField.text.length > 0){
        
        // Has sent message to User Chat
        self.hasSentMsgg = YES;
        
        [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        NSDate *nowDate = [NSDate date];
        
        // Push notification to user chat
        if (self.currentChannel.members.count <= 1) {
            [self sendRequestChatWithMessage:self.messageTextField.text];
        }
        else{
            // Only trigger a client event once a subscription has been successfully registered with Pusher
            [self.currentChannel triggerEventNamed:kEventNameNewMessage data:@{kObjectId:self.currentUser.objectId,
                                                                               kMessageContentKey:self.messageTextField.text,
                                                                               kMessageTimeCreatedKey:[NSDateFormatter stringWithDefaultFormatFromDate:nowDate]}];
        }
        
        PSCBubbleData *bubbleData = [[PSCBubbleData alloc] initWithText:self.messageTextField.text
                                                            timeCreated:nowDate
                                                                   type:BubbleTypeMine];
        [self addNewRowWithBubbleData:bubbleData];
        
        // Save message chat to history on Parse
        PFObject *messageChat = [PFObject objectWithClassName:kMessageClassKey];
        
        [messageChat setObject:self.currentUser.objectId forKey:kMessageUserSendIdKey];
        [messageChat setObject:self.userChat.objectId forKey:kMessageUserReceiveIdKey];
        [messageChat setObject:self.currentUser forKey:kMessageUserSendKey];
        [messageChat setObject:self.userChat forKey:kMessageUserReceiveKey];
        [messageChat setObject:self.messageTextField.text forKey:kMessageContentKey];
        [messageChat setObject:nowDate forKey:kMessageTimeCreatedKey];
        [messageChat setObject:[NSNumber numberWithBool:NO] forKey:kMessageStatusKey];
        
        [messageChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
               NSLog(@"[parse] Save message chat successfully!");
            }
            else{
               NSLog(@"[parse] Couldn't save your message chat.");
            }
        }];
        
        self.messageTextField.text = @"";
        
        NSLog(@"[pusher] Count channel members: %ld", (long)self.currentChannel.members.count);
    }
}

#pragma mark - Methods

- (void)refreshData
{
    [self subscribeToPresenceChannel];
    
    NSString *predicateFormatString = [NSString stringWithFormat:@"(%@ = '%@' OR %@ = '%@') AND (%@ = '%@' OR %@ = '%@')",
                                                                kMessageUserSendIdKey, self.currentUser.objectId,
                                                                kMessageUserSendIdKey, self.userChat.objectId,
                                                                kMessageUserReceiveIdKey, self.currentUser.objectId,
                                                                kMessageUserReceiveIdKey, self.userChat.objectId];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormatString];
    
    PFQuery *query = [PFQuery queryWithClassName:kMessageClassKey predicate:predicate];
    [query addAscendingOrder:kMessageTimeCreatedKey];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.bubblesdataArray = [[NSMutableArray alloc] init];
            if (objects.count > 0) {
                for (PFObject *messageChatObject in objects) {
                    
                    NSBubbleType type = BubbleTypeSomeoneElse;
                    NSString *userIdSendString = messageChatObject[kMessageUserSendIdKey];
                    // Check if current user is a sender
                    if ([self.currentUser.objectId isEqualToString:userIdSendString]) {
                        type = BubbleTypeMine;
                    }
                    
                    PSCBubbleData *bubbleData = [[PSCBubbleData alloc] initWithText:messageChatObject[kMessageContentKey]
                                                                        timeCreated:messageChatObject[kMessageTimeCreatedKey]
                                                                               type:type];
                    [self.bubblesdataArray addObject:bubbleData];
                }
                [self.tableView reloadData];
                [self scrollBubbleViewToBottomAnimated:NO];
            }
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)sendRequestChatWithMessage:(NSString *)message
{
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"UserId" equalTo:self.userChat.objectId];
    
    NSString *alertTitle = [NSString stringWithFormat:@"%@: %@", self.userChat[@"profile"][@"name"], message];
    
    // Convert NSDate to NSString
    NSString *timeCreated = [NSDateFormatter stringWithDefaultFormatFromDate:[NSDate date]];
    
    PFPush *push = [PFPush push];
    [push setData:@{@"aps":@{@"alert": alertTitle, @"sound": @"default"}, @"UserId": self.currentUser.objectId, kMessageTimeCreatedKey:timeCreated}];
    [push setQuery:pushQuery];
    
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
             NSLog(@"[pusher] push successfully!");
        }
        else{
            NSLog(@"[pusher] push has some problems: %@]", [error localizedDescription]);
        }
    }];
}

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
    NSString *channelName = [[PSCAppDelegate shareDelegate] generateUniqueChannelNameWithUserId:self.currentUser.objectId
                                                                                      andUserId:self.userChat.objectId];
    // Check channel exist or not
    PSCChannel *channel = [[PSCChannelManager shareInstance] getChannelByName:channelName];
    if (!channel) {
        self.currentChannel = [[PSCAppDelegate shareDelegate].pusherClient subscribeToPresenceChannelNamed:channelName delegate:self];
        
        // Add channel to manager
        NSMutableArray *usersArray = [NSMutableArray new];
        [usersArray addObject:self.currentUser];
        [usersArray addObject:self.userChat];
        
        PSCChannel *channel = [[PSCChannel alloc] initWithPresenceChannel:self.currentChannel
                                                                     andUserName:channelName
                                                                   anhUsersArray:usersArray];
        [[PSCChannelManager shareInstance] addNewChannel:channel];
    }
    else{
        self.currentChannel = channel.presenceChannel;
        
        // Unbind prev event
        [self.currentChannel removeAllBindings];
    }
    
    // Bind to event to receive data
    [self.currentChannel bindToEventNamed:kEventNameNewMessage handleWithBlock:^(PTPusherEvent *channelEvent){
        
        self.hasSentMsgg = YES;
        
        NSString *userSendIdString = channelEvent.data[kObjectId];
        NSString *messageString = channelEvent.data[kMessageContentKey];
        NSString *timeCreatedString = channelEvent.data[kMessageTimeCreatedKey];
        NSDate *timeCreatedDate = [NSDateFormatter dateWithDefaultFormatFromString:timeCreatedString];
        
        PSCBubbleData *bubbleData = [[PSCBubbleData alloc] initWithText:messageString
                                                               timeCreated:timeCreatedDate
                                                                   type:BubbleTypeSomeoneElse];
        [self addNewRowWithBubbleData:bubbleData];
        
        // If User is not in chat screen ---> Show notifications to Tab "Messages" and update Message Screen
        if(![PSCAppDelegate shareDelegate].isChatScreenVisible) {
            
            [[PSCAppDelegate shareDelegate] addBadgeValueToMessagesTab:messageString];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewMessageComming
                                                                object:nil
                                                                 userInfo:@{kObjectId:userSendIdString,
                                                                            kMessageContentKey:messageString,
                                                                            kMessageTimeCreatedKey:timeCreatedString,
                                                                            kMessageStatusKey:[NSNumber numberWithBool:NO]}];
        }
    }];
}

- (void)scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastRowIdx = self.bubblesdataArray.count - 1;
    
    if (lastRowIdx >= 0)
    {
    	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRowIdx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
