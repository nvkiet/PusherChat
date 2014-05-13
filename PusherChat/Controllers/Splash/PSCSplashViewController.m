//
//  PSCSplashViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCSplashViewController.h"
#import "PSCAppDelegate.h"

@interface PSCSplashViewController ()

@end

@implementation PSCSplashViewController

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

- (void)viewDidAppear:(BOOL)animated
{
    // Check If User is cached and wheather user's account linked to facebook
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [[PSCAppDelegate shareDelegate] showHomeScreen];
    }
    else {
        [[PSCAppDelegate shareDelegate] showLoginScreen];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
