//
//  PSCMessageCell.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/18/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCMessageCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PSCMessageCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end

@implementation PSCMessageCell

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
    PFObject *messageChat = (PFObject *)model;
    
    self.contentLabel.text = messageChat[kMessageContentKey];
    
    NSDate *createdAtDate = messageChat.createdAt;
    self.dateLabel.text = [self convertDateToStringWithDate:createdAtDate];
    
    PFUser *userSend = messageChat[kMessageUserSendKey];
    
    // FIXME: Repeat source and use constants string
    self.nameLabel.text = userSend[@"profile"][@"name"];
    
    if (userSend[@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:userSend[@"profile"][@"pictureURL"]];
        [self.avatarImageView setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
        
        self.avatarImageView.layer.cornerRadius = 20.0;
        self.avatarImageView.layer.masksToBounds = YES;
    }
}

- (NSString *)convertDateToStringWithDate:(NSDate *)date
 {
    // TODOME: format date like: 12:31 pm, Yesterday, 9/5/14
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    return [NSString stringWithFormat:@"%d/%d/%d", [components day], [components month], [components year]];
}
@end
