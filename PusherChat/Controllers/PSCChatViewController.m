//
//  PSCChatViewController.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/12/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChatViewController.h"

@interface PSCChatViewController ()
@property (weak, nonatomic) IBOutlet UILabel *receiveMessageLabel;
@property (weak, nonatomic) IBOutlet UITextField *sendMessageTextField;

@end

@implementation PSCChatViewController

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
}

#pragma mark - Actions

- (IBAction)btnSendMessage:(id)sender
{
    if (self.sendMessageTextField.text.length > 0) {
//        [self.client sendEventNamed:@"new-message" data:@{@"text": self.sendMessageTextField.text} channel:@"chat"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
