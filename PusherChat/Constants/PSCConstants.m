//
//  PSCConstants.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/19/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCConstants.h"



#pragma mark - Notifications

NSString *const kNotificationAppWillEnterForeground = @"AppWillEnterForeground";
NSString *const kNotificationNewMessageComming = @"NewMessageComming";

#pragma mark - Event Message

NSString *const kEventNameNewMessage = @"client-chat";

#pragma mark - Default Class

NSString *const kObjectId = @"objectId";

#pragma mark - Message Class

// Class key
NSString *const kMessageClassKey = @"Message";

// Field keys
NSString *const kMessageUserSendKey = @"UserSend";
NSString *const kMessageUserReceiveKey = @"UserReceive";
NSString *const kMessageContentKey = @"Content";
NSString *const kMessageCreatedAtKey = @"createdAt";

