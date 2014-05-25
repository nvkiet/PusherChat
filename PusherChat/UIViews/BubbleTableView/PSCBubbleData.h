//
//  PSCBubbleData.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/16/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum NSBubbleType
{
    BubbleTypeMine = 0,
    BubbleTypeSomeoneElse = 1
} NSBubbleType;

@interface PSCBubbleData : NSObject

@property (nonatomic) NSBubbleType type;
@property (nonatomic, strong) UIView *view;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic,strong) NSString *content;
@property (nonatomic, strong) NSDate *timeCreated;

- (id)initWithText:(NSString *)text timeCreated:(NSDate *)createAt type:(NSBubbleType)type;

@end
