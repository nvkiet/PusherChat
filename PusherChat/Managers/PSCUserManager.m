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

- (void)loginWithFacebookOnSuccess:(void(^)(PFUser *user))success failure:(void(^)(NSError *error))failure
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_birthday"];
    
    // Login PFUser using facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            failure(error);
        }
        else{
            // Update current user
            [self updateWithCurrentUser:user];
            
            success(user);
        }
    }];
}

- (void)updateWithCurrentUser:(PFUser *)user
{
    if (!self.currentUser) {
        self.currentUser = [[PSCUser alloc] init];
    }
    
    self.currentUser.access_token = user.sessionToken;
    self.currentUser.objectId = user.objectId;
    
    // TODOME: Save User using NSUserDefaults
}

@end
