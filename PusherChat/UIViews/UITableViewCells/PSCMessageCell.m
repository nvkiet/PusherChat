//
//  PSCMessageCell.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/18/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCMessageCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PSCAppDelegate.h"

@interface PSCMessageCell()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageView;
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
    
    self.dateLabel.text = @"";
    NSDate *timeCreatedDate = messageChat[kMessageTimeCreatedKey];
    if (timeCreatedDate) {
        self.dateLabel.text = [self stringFromDate:timeCreatedDate];
    }

    PFUser *currentUser = [PFUser currentUser];
    PFUser *userChat = messageChat[kMessageUserSendKey];
    
    // Check Who send message
    if ([userChat.objectId isEqualToString:currentUser.objectId]) {
        // This User is Sender
        userChat = messageChat[kMessageUserReceiveKey];
    }
    else{
        NSNumber *readNumber = messageChat[kMessageStatusKey];
        if ([readNumber boolValue]) {
            self.badgeImageView.hidden = YES;
        }
        else{
            self.badgeImageView.hidden = NO;
            
            [[PSCAppDelegate shareDelegate] addBadgeValueToMessagesTab:@""];
        }
    }
    
    // FIXME: Repeat source and use constants string
    self.nameLabel.text = userChat[@"profile"][@"name"];
    
    if (userChat[@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:userChat[@"profile"][@"pictureURL"]];
        [self.avatarImageView setImageWithURL:pictureURL placeholderImage:[UIImage imageNamed:@"anonymousUser.png"]];
        
        self.avatarImageView.layer.cornerRadius = 20.0;
        self.avatarImageView.layer.masksToBounds = YES;
    }
}

// Format date like: 12:31 pm, Yesterday, Thursday, 9/5/14
- (NSString *)stringFromDate:(NSDate *)date
 {
     if (date) {
         NSCalendar* calendar = [NSCalendar currentCalendar];
         NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
         
         NSDate * nowDate = [NSDate date];
         int differenceInDays =
             [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:[NSDateFormatter dateWithDefaultFormatFromDate:date]] -
             [calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:[NSDateFormatter dateWithDefaultFormatFromDate:nowDate]];
         
         NSString *dayString = nil;
         if (differenceInDays == 0) {
             NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
             [timeFormatter setDateFormat:@"HH:mm a"];
             [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
             dayString = [timeFormatter stringFromDate:date];
         }
         else if (differenceInDays == -1){
             dayString = @"Yesterday";
         }
         else if (differenceInDays < -1 && differenceInDays >= -6){
             NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
             [dayFormat setDateFormat:@"EEEE"];
             dayString = [[NSString alloc] initWithFormat:@"%@",[dayFormat stringFromDate:date]];
         }
         else{
             dayString = [NSString stringWithFormat:@"%d/%d/%d",[components day],[components month],[components year]];
         }
         return dayString;
     }
     return @"";
}
@end
