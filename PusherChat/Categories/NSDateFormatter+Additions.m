//
//  NSDateFormatter+Additions.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/25/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "NSDateFormatter+Additions.h"

@implementation NSDateFormatter (Additions)

+ (NSDate *)dateWithDefaultFormatFromString:(NSString *)string
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSDate *date = [dateFormatter dateFromString:string];
    
    return date;
}

+ (NSString *)stringWithDefaultFormatFromDate:(NSDate *)date
{
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        
        NSString *string = [dateFormatter stringFromDate:date];
        
        return string;
    }
    return @"";
}

@end
