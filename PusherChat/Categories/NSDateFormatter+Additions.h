//
//  NSDateFormatter+Additions.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/25/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (Additions)

+ (NSDate *)dateWithDefaultFormatFromString:(NSString *)string;
+ (NSString *)stringWithDefaultFormatFromDate:(NSDate *)date;
+ (NSDate *)dateWithDefaultFormatFromDate:(NSDate *)date;

@end
