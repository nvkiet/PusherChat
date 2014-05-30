//
//  NSString+Utils.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/30/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (NSString *)normalizeVietnameseString
{
    NSMutableString *originStr = [NSMutableString stringWithString:self];
    CFStringNormalize((CFMutableStringRef)originStr, kCFStringNormalizationFormD);
    
    CFStringFold((CFMutableStringRef)originStr, kCFCompareDiacriticInsensitive, NULL);
    
    NSString *finalString1 = [originStr stringByReplacingOccurrencesOfString:@"u0111"withString:@"d"];
    
    NSString *finalString2 = [finalString1 stringByReplacingOccurrencesOfString:@"u0110"withString:@"D"];
    
    return finalString2;
}

@end
