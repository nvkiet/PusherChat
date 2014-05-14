//
//  UIImage+Utils.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/14/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

+ (UIImage *)imageRenderingModeAlwaysOrigininalWithName:(NSString *)name
{
    return [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
