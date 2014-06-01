//
//  PSCMoreViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCMoreViewController.h"
#import "PSCAppDelegate.h"
#import <MessageUI/MessageUI.h>

@interface PSCMoreViewController ()<UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UITableViewCell *shareCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *iconsArray;
@end

@implementation PSCMoreViewController

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
    
    self.navigationItem.title = @"More";
    
    UIBarButtonItem *logOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutButtonClicked:)];
    self.navigationItem.rightBarButtonItem = logOutButton;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self initListButtonIcons];
    
    if ([PFUser currentUser]) {
        [self updateProfile];
    }
    
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSDictionary *userData = (NSDictionary*)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] init];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }
            
            if (userData[@"birthday"]) {
                userProfile[@"birthday"] = userData[@"birthday"];
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            // FIXME: Could't get this field
            if (userData[@"phone"]) {
                userProfile[@"phone"] = userData[@"phone"];
            }
            
            // FIXME: Could't get this field
            if (userData[@"username"]) {
                userProfile[@"username"] = userData[@"username"];
            }

            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            // Save user info
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self updateProfile];
        }
        else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"] isEqualToString:@"OAuthException"]){
            NSLog(@"The facebook session was invalidated");
            [[PSCAppDelegate shareDelegate] logOut];
        }
        else {
            NSLog(@"Some other error: %@", error);
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kMoreScreenTableViewShareSectionRowIndex) {
        self.shareCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.shareCell;
    }
    else{
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.font =[UIFont boldSystemFontOfSize:14];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor= [UIColor whiteColor];
        }
        
        switch (indexPath.section) {
            case 0:
                cell.textLabel.text = @"MORE APPS";
                break;
            case 1:
                cell.textLabel.text = @"LOVE PUSHERCHAT";
                break;
            case 2:
                cell.textLabel.text = @"EMAIL FEEDBACK";
                break;
            default:
                break;
        }
        
        cell.imageView.image= [self.iconsArray objectAtIndex:indexPath.section];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kMoreScreenTableViewShareSectionRowIndex) {
        return 80;
    }
    return 40;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kMoreScreenTableViewShareSectionRowIndex) {
        return @"Share to your friends";
    }
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: //More apps
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/artist/kiet-nguyen/id751705948"]];
            break;
        case 1: //Rating: Need app id
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=766553064&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
            break;
        case 2: //Email To FeedBack
        {
            if ([MFMailComposeViewController canSendMail]){
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                [mailer setSubject:@"[PusherChat.iOS] Feedback"];
                NSArray *toRecipients = [NSArray arrayWithObjects:@"nguyenvankiet.teaching@gmail.com", nil];
                [mailer setToRecipients:toRecipients];
                
                //Set body
                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                NSString *appVersion = infoDictionary[(NSString*)kCFBundleVersionKey];
                
                float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
                NSString *systemName = [[UIDevice currentDevice] systemName];
                
                NSString *emailBody = [NSString stringWithFormat:@"\n\n\n\n=== Application infomation === \n -- (Please do not remove) -- \n PusherChat.iOS.v%@\n%@ %1.3f\n===========================", appVersion, systemName, iOSVersion];
                [mailer setMessageBody:emailBody isHTML:NO];
                
                [self presentViewController:mailer animated:YES completion:nil];
            }
            else{
               [self showAlertErrorCannotSendMail];
            }
            
            break;
        }
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)shareViaMessageTouched:(id)sender
{
    MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]){
        messageVC.body = [NSString stringWithFormat:@"Hey, I started using PusherChat. It's an awesome free app for free text messages! - www.pusherchat.com"];
        messageVC.messageComposeDelegate = self;
        
        [self presentViewController:messageVC animated:YES completion:nil];
    }
}

- (IBAction)shareViaMailTouched:(id)sender
{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Invitation to PusherChat"];
        
        //Set body
        NSString *emailBody = [NSString stringWithFormat:@"Hey, \n\n I started using PusherChat. It's an awesome free app for free text messages! \n\n Get PusherChat: www.pusherchat.com \n\n Yours,"];
        [mailer setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else{
        [self showAlertErrorCannotSendMail];
    }

}

- (void)logOutButtonClicked:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:nil message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil] show];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[PSCAppDelegate shareDelegate] logOut];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - Methods

- (void)showAlertErrorCannotSendMail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                    message:@"Email composition failure. Please try again."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)initListButtonIcons
{
    self.iconsArray = [[NSMutableArray alloc] init];
    
    UIImage *image= [UIImage imageNamed:@"more_apps_icon.png"];
    [self.iconsArray addObject:image];
    
    image = [UIImage imageNamed:@"love_icon.png"];
    [self.iconsArray addObject:image];
    
    image = [UIImage imageNamed:@"feedback_icon.png"];
    [self.iconsArray addObject:image];
}

- (void)updateProfile
{
    PFUser *currentUser = [PFUser currentUser];
    
    // TODOME: Update to current User
    
    self.nameLabel.text = [[PSCAppDelegate shareDelegate]getNameOfUserObject:currentUser];
    
    if ([currentUser objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[currentUser objectForKey:@"profile"][@"pictureURL"]];
        
        [self.avatarImageView setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
        
        self.avatarImageView.layer.cornerRadius = 45;
        self.avatarImageView.layer.masksToBounds = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
