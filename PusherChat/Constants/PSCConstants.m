//
//  PSCConstants.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/19/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCConstants.h"

int const kMoreScreenTableViewShareSectionRowIndex = 3;
NSString * const kUserAnonymous = @"Anonymous";

#pragma mark - Share to your friends

NSString * const kFacebookShareMessage = @"I'm using PusherChat to send free messages on my iPhone www.pusherchat.com";

#pragma mark - Notification fields

NSString * const kIsSender = @"IsSender";
NSString * const kMessageAutoNavigationKey = @"AutoNavigation";

#pragma mark - Notifications

NSString * const kNotificationAppWillEnterForeground = @"AppWillEnterForeground";
NSString * const kNotificationNewMessageComming = @"NewMessageComming";

#pragma mark - Event Message

NSString * const kEventNameNewMessage = @"client-chat";

#pragma mark - Default Class

NSString * const kObjectId = @"objectId";

#pragma mark - Message Class

// Class key
NSString * const kMessageClassKey = @"Message";

// Field keys
NSString * const kMessageUserSendKey      = @"UserSend";
NSString * const kMessageUserReceiveKey   = @"UserReceive";
NSString * const kMessageContentKey       = @"Content";
NSString * const kMessageTimeCreatedKey   = @"TimeCreated";
NSString * const kMessageUserSendIdKey    = @"UserSendId";
NSString * const kMessageUserReceiveIdKey = @"UserReceiveId";
NSString * const kMessageStatusKey        = @"Status";
