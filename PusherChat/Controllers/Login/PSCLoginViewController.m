//
//  PSCLoginViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCLoginViewController.h"

@interface PSCLoginViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation PSCLoginViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)loginClicked:(id)sender
{
    [[PSCUserManager sharedInstance] loginWithFacebookOnSuccess:^(PFUser *user) {
        [_activityIndicator stopAnimating];
        if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        else {
            NSLog(@"User with facebook logged in!");
            [self dismissViewControllerAnimated:NO completion:nil];
        }

    } failure:^(NSError *error) {
        if (!error) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Failed" message:@"Make sure you've allowed ILoveDogs to use Facebook in iOS Settings > Privacy > Facebook." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
        else {
            NSLog(@"Uh oh. An error occurred: %@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Failed" message:@"The Internet connection appears to be offline." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }];
    
    [_activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
