//
//  PSCContactCell.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCContactCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PSCContactCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end

@implementation PSCContactCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureDataWithModel: (id)model
{
    PFUser *user = (PFUser *)model;
    
    self.nameLabel.text = user[@"profile"][@"name"];
    
    NSURL *pictureURL = [NSURL URLWithString:user[@"profile"][@"pictureURL"]];
    [self.avatarImageView setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
    
    self.avatarImageView.layer.cornerRadius = 20.0;
    self.avatarImageView.layer.masksToBounds = YES;
}

@end
