//
//  PSCMoreViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCMoreViewController.h"
#import "PSCAppDelegate.h"

@interface PSCMoreViewController ()<NSURLConnectionDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) NSMutableData *imageData;
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


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.avatarImageView.image = [UIImage imageWithData:self.imageData];
    
    self.avatarImageView.layer.cornerRadius = 50;
    self.avatarImageView.layer.masksToBounds = YES;
}

#pragma mark - Methods

- (void)updateProfile
{
    PFUser *currentUser = [PFUser currentUser];
    
    // TODOME: Update to current User
    
    self.nameLabel.text = [currentUser objectForKey:@"profile"][@"name"];

    self.imageData      = [[NSMutableData alloc] init];
    
    if ([currentUser objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL              = [NSURL URLWithString:[currentUser objectForKey:@"profile"][@"pictureURL"]];
        NSURLRequest *urlRequest       = [NSURLRequest requestWithURL:pictureURL
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:2.0f];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
