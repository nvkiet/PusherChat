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

- (id)initWithText:(NSString *)text type:(NSBubbleType)type;

@end
