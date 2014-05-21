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

@interface PSCMessagesViewController ()<UITableViewDelegate, UITableViewDataSource>
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
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNewMessageCommingWithChannelData:) name:kNotificationNewMessageComming object:nil];
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
    
    PFObject *messageChat = [self.messagesDataArray objectAtIndex:indexPath.row];
    [cell configureDataWithModel:messageChat];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *messageChat = [self.messagesDataArray objectAtIndex:indexPath.row];
    
    PSCChatViewController *chatVC = [[PSCChatViewController alloc] initWithNibName:NSStringFromClass([PSCChatViewController class]) bundle:nil];
    chatVC.userChat = messageChat[kMessageUserSendKey];
    
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - Methods

- (void)updateNewMessageCommingWithChannelData:(NSNotification*)aUserInfo
{
    NSDictionary *channelData = aUserInfo.userInfo;
    
    NSString *userId = channelData[kObjectId];
    NSString *message = channelData[kMessageContentKey];
    // FIXME: Coundn't update time received message chat
    NSDate *timeReceived = channelData[kMessageCreatedAtKey];
    
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
}

- (void)refreshData
{
    self.messagesDataArray = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:kMessageClassKey];
    [query whereKey:kMessageUserReceiveKey equalTo:[PFUser currentUser]]; 
    [query addDescendingOrder:kMessageCreatedAtKey];
    [query includeKey:kMessageUserSendKey];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // Get the last message
            NSArray *arrUserSends = [objects valueForKey:kMessageUserSendKey];
            NSSet *uniqueUserIdSendSet = [NSSet setWithArray:[arrUserSends valueForKey:kObjectId]];
            NSArray *uniqueUserIdSendArray = [uniqueUserIdSendSet allObjects];
            
            for (NSString *userIdSend in uniqueUserIdSendArray) {
                PFObject *messageChat = [self getMessageChatInArray:objects withUserIdSend:userIdSend];
                [self.messagesDataArray addObject:messageChat];
            }
            
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (PFObject *)getMessageChatInArray:(NSArray *)objects withUserIdSend:(NSString *)theUserIdSend
{
    for (PFObject *object in objects) {
        PFObject *tmpUser = object[kMessageUserSendKey];
        NSString *userIdSend = tmpUser.objectId;
        
        if ([userIdSend isEqualToString:theUserIdSend]) {
            return object;
        }
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
