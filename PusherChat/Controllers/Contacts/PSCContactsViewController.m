//
//  PSCContactsViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCContactsViewController.h"
#import "PSCContactCell.h"
#import "PSCChatViewController.h"
#import "PSCAppDelegate.h"

@interface PSCContactsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *contactsDataArray;
@property (nonatomic, strong) NSMutableArray *resultsDataArray;
@property (nonatomic, strong) NSTimer *myTimer;

@property (nonatomic, strong) UIRefreshControl *pullRefreshControl;
@end

@implementation PSCContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = @"Contacts";
    
    self.pullRefreshControl = [[UIRefreshControl alloc] init];
    [self.pullRefreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:self.pullRefreshControl];
    
    [self refreshData];
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
         return [self.contactsDataArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PSCContactCell";
    
    PSCContactCell *cell = (PSCContactCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] firstObject];
    }
    
    PFUser *user = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user =  [self.resultsDataArray objectAtIndex:indexPath.row];
    }
    else{
        user =  [self.contactsDataArray objectAtIndex:indexPath.row];
    }
    
    [cell configureDataWithModel:user];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFUser *user = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user =  [self.resultsDataArray objectAtIndex:indexPath.row];
    }
    else{
        user =  [self.contactsDataArray objectAtIndex:indexPath.row];
    }
    
    PSCChatViewController *chatVC = [[PSCChatViewController alloc] initWithNibName:NSStringFromClass([PSCChatViewController class]) bundle:nil];
    chatVC.userChat = user;
    
    [self.navigationController pushViewController:chatVC animated:YES];
    
    // Deselect on cell
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

    for (PFUser *userObject in self.contactsDataArray) {
        NSString *name = [[[[PSCAppDelegate shareDelegate] getNameOfUserObject:userObject] lowercaseString] normalizeVietnameseString];
        
        if (!([name rangeOfString:searchText].location == NSNotFound)) {
            [self.resultsDataArray addObject:userObject];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - Methods

- (void)refreshData
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.contactsDataArray = objects;
            
            [self.tableView reloadData];
            
            [self.pullRefreshControl endRefreshing];
        }
        else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
