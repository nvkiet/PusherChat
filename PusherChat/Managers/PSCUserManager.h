//
//  PSCUserManager.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCUserManager : NSObject

@property (nonatomic, strong) PSCUser *currentUser;

+ (instancetype)sharedInstance;

- (NSString *)getAccessToken;

- (void)loginWithFacebookOnSuccess: (void(^)(PFUser *user))success failure:(void(^)(NSError *error))failure;

@end
