//
//  PSCMessagesViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCMessagesViewController.h"
#import "PSCMessageCell.h"
#import "PSCChatViewController.h"
#import "PSCAppDelegate.h"

@interface PSCMessagesViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *messagesDataArray; // Last messages of UserChat
@property (nonatomic, strong) NSTimer *myTimer;
@property (nonatomic, strong) NSMutableArray *resultsDataArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PSCMessagesViewController

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.title = @"Messages";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kNotificationAppWillEnterForeground object:nil];
    
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
   [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(updateNewMessageCommingWithChannelData:)
                                         name:kNotificationNewMessageComming object:nil];
    
    [self checkToRemoveBadgeValueOnMessagesTab];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)checkToRemoveBadgeValueOnMessagesTab
{
    // Get the last User Chat
    PFUser *currentUser = [PFUser currentUser];
    
    for (PFObject *messageChatObject in self.messagesDataArray) {
        PFUser *userChat = messageChatObject[kMessageUserSendKey];
        
        // Check who send message
        if (![userChat.objectId isEqualToString:currentUser.objectId]) {
            // This User is reveiver
            NSNumber *statusNumber = messageChatObject[kMessageStatusKey];
            if (![statusNumber boolValue]) { // Status is un-read
                return;
            }
        }
    }
    
    [[PSCAppDelegate shareDelegate] removeBadgeValueToMessagesTab];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.resultsDataArray count];
    }
    else{
        return [self.messagesDataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PSCMessageCell";
    
    PSCMessageCell *cell = (PSCMessageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] firstObject];
    }
    
    PFObject *messageChat = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (indexPath.row >= 0 && indexPath.row < [self.resultsDataArray count]) {
            messageChat =  [self.resultsDataArray objectAtIndex:indexPath.row];
        }
    }
    else{
        if (indexPath.row >= 0 && indexPath.row < [self.messagesDataArray count]) {
            messageChat =  [self.messagesDataArray objectAtIndex:indexPath.row];
        }
    }
    
    if (messageChat) {
        [cell configureDataWithModel:messageChat];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *messageChat = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        messageChat =  [self.resultsDataArray objectAtIndex:indexPath.row];
    }
    else{
        messageChat =  [self.messagesDataArray objectAtIndex:indexPath.row];
    }
    
    if (messageChat){
     // Get the last User Chat
     PFUser *currentUser = [PFUser currentUser];
     PFUser *userChat = messageChat[kMessageUserSendKey];
     
     // Check who send message
     if ([userChat.objectId isEqualToString:currentUser.objectId]) {
         // This User is Sender
         userChat = messageChat[kMessageUserReceiveKey];
     }
     else{
         // Update message chat status
         NSNumber *statusNumber = messageChat[kMessageStatusKey];
         if (![statusNumber  boolValue]) { // Status is UnRead
             
             // Update local
             messageChat[kMessageStatusKey] = [NSNumber numberWithBool:YES];
             NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
             [self reloadRowsAtIndexPaths:@[destinationIndexPath]];
             self.messagesDataArray[indexPath.row] = messageChat;
             
             // Retrieve and Update the last message chat status to Parse
             // FIXME: Maybe get the wrong last message object
             PFQuery *query = [PFQuery queryWithClassName:kMessageClassKey];
             [query whereKey:kMessageContentKey equalTo:messageChat[kMessageContentKey]];
             
             // Get the first object in result array
             [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                 if (!object) {
                     NSLog(@"[parse] The getFirstObject request failed.");
                 }
                 else{
                     PFObject *lastMessageChat = object;
                     lastMessageChat[kMessageStatusKey] = [NSNumber numberWithBool:YES];
                     
                     [lastMessageChat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             NSLog(@"[parse] Update message chat successfully!");
                         }
                         else{
                             NSLog(@"[parse] Couldn't update your message chat.");
                         }
                     }];
                     NSLog(@"[parse] Successfully retrieved the object.");
                 }
             }];
         }

     }
     
     PSCChatViewController *chatVC = [[PSCChatViewController alloc] initWithNibName:NSStringFromClass([PSCChatViewController class]) bundle:nil];
     chatVC.userChat = userChat;
     
     [self.navigationController pushViewController:chatVC animated:YES];
     
     // Deselect on cell
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (self.myTimer){
        // Stop a timer before it fires
        if ([self.myTimer isValid]){
            [self.myTimer invalidate];
        }
        self.myTimer = nil;
    }
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self
                                                  selector:@selector(filterContentForSearchText:)
                                                  userInfo:searchText repeats:NO];
}

// Search contacts in contacts data array
- (void)filterContentForSearchText:(NSTimer*)theTimer
{
    self.resultsDataArray = [NSMutableArray new];
    
    NSString *searchText = [[(NSString*)[theTimer userInfo] lowercaseString] normalizeVietnameseString];
    
    PFUser *currentUser = [PFUser currentUser];
    
    for (PFObject *messageChatObject in self.messagesDataArray) {
        
        PFUser *userChat = messageChatObject[kMessageUserSendKey];
        // Check Who send message
        if ([userChat.objectId isEqualToString:currentUser.objectId]) {
            // This User is Sender
            userChat = messageChatObject[kMessageUserReceiveKey];
        }

        NSString *name = [[[[PSCAppDelegate shareDelegate] getNameOfUserObject:userChat] lowercaseString] normalizeVietnameseString];
        
        if (!([name rangeOfString:searchText].location == NSNotFound)) {
            [self.resultsDataArray addObject:messageChatObject];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Methods

// Update one message cell when new message commming == Last message chat
- (void)updateNewMessageCommingWithChannelData:(NSNotification*)aUserInfo
{
    NSDictionary *channelData = aUserInfo.userInfo;
    
    NSString *userSendIdString = channelData[kObjectId];
    NSString *contentString = channelData[kMessageContentKey];
    NSString *timeCreatedString = channelData[kMessageTimeCreatedKey];
    NSDate *timeCreatedDate = [NSDateFormatter dateWithDefaultFormatFromString:timeCreatedString];
    
    // Find User Cell to update new message
    int row = -1;
    for (int i = 0 ; i< self.messagesDataArray.count;  i++) {
        PFObject *messageChat =  [self.messagesDataArray objectAtIndex:i];
        
        NSString *tmpUserSendId = messageChat[kMessageUserSendIdKey];
        NSString *tmpUserReceiveId = messageChat[kMessageUserReceiveIdKey];
        
        // Find user is Chatting
        if ([tmpUserSendId isEqualToString:userSendIdString] || [tmpUserReceiveId isEqualToString:userSendIdString]) {
            // TODOME: Update all fields in Message class
            // FIXME: It's not the last message object
            messageChat[kMessageContentKey] = contentString;
            messageChat[kMessageTimeCreatedKey] = timeCreatedDate;
            messageChat[kMessageStatusKey] = channelData[kMessageStatusKey];
            
            BOOL isLastMessageObject = NO;
            
            // Check UserChat is Sender or receiver
            NSNumber *isSenderNumber = channelData[kIsSender];
            if (isSenderNumber) {
                if (![isSenderNumber boolValue]) { // Userchat is receiver
                    if (![userSendIdString isEqualToString:tmpUserReceiveId]) {
                        // Permutatation
                        messageChat = [self permutateSenderToReceiver:messageChat];
                        
                        isLastMessageObject = YES;
                    }
                }
            }
            
            // UserChat is Sender
            if (![userSendIdString isEqualToString:tmpUserSendId] && !isLastMessageObject) {
                messageChat = [self permutateSenderToReceiver:messageChat];
            }
            
            self.messagesDataArray[i] = messageChat;
            row = i;
            break;
        }
    }
    
    if (row >= 0) {
        NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
        NSIndexPath *destinationIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        if (row > 0) {
            // Move cell to the Top
            PFObject *messageChatObject = [self.messagesDataArray objectAtIndex:row];
            [self.messagesDataArray removeObjectAtIndex:row];
            [self.messagesDataArray insertObject:messageChatObject atIndex:0];
            
            [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        }
        [self reloadRowsAtIndexPaths:@[destinationIndexPath]];
        
        // TODOME: Auto navigate to chat screen If User touchs a notification
    }
    else{
        [self refreshData];
        
        // TODOME: Auto navigate to chat screen If User touchs a notification
    }
}

// Do permutatation
- (PFObject *)permutateSenderToReceiver:(PFObject *)messageChatObject
{
    PFObject *tmpObject = messageChatObject[kMessageUserSendKey];
    messageChatObject[kMessageUserSendKey] = messageChatObject[kMessageUserReceiveKey];
    messageChatObject[kMessageUserReceiveKey] = tmpObject;
    
    NSString *tmpString = messageChatObject[kMessageUserSendIdKey];
    messageChatObject[kMessageUserSendIdKey] = messageChatObject[kMessageUserReceiveIdKey];
    messageChatObject[kMessageUserReceiveIdKey] = tmpString;
    
    return messageChatObject;
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)refreshData
{
    PFUser *currentUser = [PFUser currentUser];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = '%@' OR %@ = '%@'",
                                                               kMessageUserSendIdKey, currentUser.objectId,
                                                               kMessageUserReceiveIdKey, currentUser.objectId]];
    
    PFQuery *query = [PFQuery queryWithClassName:kMessageClassKey predicate:predicate];
    [query addDescendingOrder:kMessageTimeCreatedKey];
    [query includeKey:kMessageUserSendKey];
    [query includeKey:kMessageUserReceiveKey];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messagesDataArray = [NSMutableArray new];
            if (objects.count > 0) {
                [self.messagesDataArray addObject:objects[0]];
                for (int i = 1; i < objects.count; i++) {
                    PFObject *messageChat = [objects objectAtIndex:i];
                    if (![self isExistWithMessageChat:messageChat]){
                        [self.messagesDataArray addObject:messageChat];
                    }
                }
                [self.tableView reloadData];
                
                [self checkToRemoveBadgeValueOnMessagesTab];
            }
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (BOOL)isExistWithMessageChat:(PFObject *)object
{
    BOOL result = FALSE;
    
    NSString *userIdSend_B = object[kMessageUserSendIdKey];
    NSString *userIdReceive_B = object[kMessageUserReceiveIdKey];
    
    for (PFObject *messageChat in self.messagesDataArray) {
        
        NSString *userIdSend_A = messageChat[kMessageUserSendIdKey];
        NSString *userIdReceive_A = messageChat[kMessageUserReceiveIdKey];
        
        if (([userIdSend_B isEqualToString:userIdSend_A] && [userIdReceive_B isEqualToString:userIdReceive_A]) ||
           ([userIdSend_B isEqualToString:userIdReceive_A] && [userIdReceive_B isEqualToString:userIdSend_A]))  {
            result = YES;
            break;
        }
    }
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
