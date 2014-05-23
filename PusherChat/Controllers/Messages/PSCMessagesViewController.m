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

@interface PSCMessagesViewController ()<UITableViewDelegate, UITableViewDataSource, PSCChatVCDelegate>
@property (nonatomic, strong) NSMutableArray *messagesDataArray;

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
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.navigationItem.title = @"Messages";
    
    [self refreshData];
}


- (void)viewWillAppear:(BOOL)animated
{
   [[NSNotificationCenter defaultCenter] addObserver:self
                                         selector:@selector(updateNewMessageCommingWithChannelData:)
                                         name:kNotificationNewMessageComming object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PSCMessageCell";
    
    PSCMessageCell *cell = (PSCMessageCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] firstObject];
    }
    
    if (indexPath.row >= 0 && indexPath.row < self.messagesDataArray.count) {
        PFObject *messageChat = [self.messagesDataArray objectAtIndex:indexPath.row];
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
     if (indexPath.row >= 0 && indexPath.row < self.messagesDataArray.count) {
         PFObject *messageChat = [self.messagesDataArray objectAtIndex:indexPath.row];
         
         // Get the last User Chat
         PFUser *currentUser = [PFUser currentUser];
         PFUser *userChat = messageChat[kMessageUserSendKey];
         
         if ([userChat.objectId isEqualToString:currentUser.objectId]) {
             userChat = messageChat[kMessageUserReceiveKey];
         }
         
         PSCChatViewController *chatVC = [[PSCChatViewController alloc] initWithNibName:NSStringFromClass([PSCChatViewController class]) bundle:nil];
         chatVC.userChat = userChat;
         chatVC.delegate = self;
         
         [self.navigationController pushViewController:chatVC animated:YES];
     }
}

#pragma mark - ChatVCDelegate

- (void)chatViewControllerRefreshData:(PSCChatViewController *)chatVC
{
    [self refreshData];
}

#pragma mark - Methods

- (void)updateNewMessageCommingWithChannelData:(NSNotification*)aUserInfo
{
    NSDictionary *channelData = aUserInfo.userInfo;
    
    NSString *userId = channelData[kObjectId];
    NSString *message = channelData[kMessageContentKey];
    // FIXME: Coundn't update time received message chat
    NSString *createAt = channelData[kMessageCreatedAtKey];
    
    // Find User Cell to udate new message
    int row = -1;
    for (int i = 0 ; i< self.messagesDataArray.count;  i++) {
        PFObject *messageChat =  [self.messagesDataArray objectAtIndex:i];
        PFObject *userSend = messageChat[kMessageUserSendKey];
        NSString *userSendId = userSend.objectId;
        
        if ([userSendId isEqualToString:userId]) {
            messageChat[kMessageContentKey] = message;
            self.messagesDataArray[i] = messageChat;
            row = i;
            break;
        }
    }
    
    if (row >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
    else{
        [self refreshData];
    }
}

- (void)refreshData
{
    self.messagesDataArray = [NSMutableArray new];
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = '%@' OR %@ = '%@'",
                                                               kMessageUserSendIdKey, currentUser.objectId,
                                                               kMessageUserReceiveIdKey, currentUser.objectId]];
    
    PFQuery *query = [PFQuery queryWithClassName:kMessageClassKey predicate:predicate];
    [query addDescendingOrder:kMessageCreatedAtKey];
    [query includeKey:kMessageUserSendKey];
    [query includeKey:kMessageUserReceiveKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count > 0) {
                [self.messagesDataArray addObject:objects[0]];
                
                for (int i = 1; i < objects.count; i++) {
                    
                    PFObject *messageChat = [objects objectAtIndex:i];
                    
                    if (![self isExistWithMessageChat:messageChat]){
                        [self.messagesDataArray addObject:messageChat];
                    }
                }
                
                [self.tableView reloadData];
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
