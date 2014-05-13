//
//  PSCUser.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/13/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCUser : NSObject

// Login tokens
@property (nonatomic, strong) NSString * access_token;

// Facebook Graph API
@property (nonatomic, strong) NSString * facebook_id;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSNumber * location;
@property (nonatomic, strong) NSNumber * gender;
@property (nonatomic, strong) NSString * birthdate;
@property (nonatomic, strong) NSNumber * phone;
@property (nonatomic, strong) NSString * profile_image_picture;

@end
