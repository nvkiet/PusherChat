//
//  PSCBubbleData.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/16/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCBubbleData.h"

const UIEdgeInsets textInsetsMine = {5, 10, 7, 17}; //{5, 10, 11, 17};
const UIEdgeInsets textInsetsSomeone = {5, 15, 7, 10}; //{5, 15, 11, 10};

@implementation PSCBubbleData

- (id)initWithText:(NSString *)text timeCreated:(NSDate *)createAt type:(NSBubbleType)type
{
    self = [super init];
    if (self)
    {
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        CGRect rect = [(text ? text : @"") boundingRectWithSize:CGSizeMake(220, 9999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = (text ? text : @"");
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        
        self.insets = (type == BubbleTypeMine ? textInsetsMine : textInsetsSomeone);
        self.view = label;
        self.type = type;
        
        self.content = text;
        self.timeCreated = createAt;
    }
    return self;
}

@end
