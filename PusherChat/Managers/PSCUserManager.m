//
//  PSCUserManager.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCUserManager.h"

@implementation PSCUserManager

+ (instancetype)sharedInstance
{
    static PSCUserManager *userManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userManager = [[PSCUserManager alloc] init];
    });
    return userManager;
}

- (NSString *)getAccessToken
{
    return [self.currentUser access_token];
}

@end
