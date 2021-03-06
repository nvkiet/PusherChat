//
//  PSCConstants.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/19/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PUSHER_API_KEY @"760826ac4922c8b7563a"
#define PUSHER_APP_ID  @"76720"
#define PUSHER_API_SECRET  @"b0d277089fc2d751fb8a"

#define FONT_HELVETICAL_REGULAR  @"HelveticaNeue"
#define FONT_HELVETICAL_LIGHT  @"HelveticaNeue-Light"

extern int const kMoreScreenTableViewShareSectionRowIndex;
extern NSString * const kUserAnonymous;

#pragma mark - Share to your friends

extern NSString * const kFacebookShareMessage;

#pragma mark - Notification fields

extern NSString * const kIsSender;
extern NSString * const kMessageAutoNavigationKey;

#pragma mark - Notifications

extern NSString * const kNotificationAppWillEnterForeground;
extern NSString * const kNotificationNewMessageComming;

#pragma mark - Event Message

extern NSString * const kEventNameNewMessage;

#pragma mark - Default Class

extern NSString * const kObjectId;

#pragma mark - Message Class

extern NSString * const kMessageClassKey;
extern NSString * const kMessageUserSendKey;
extern NSString * const kMessageUserReceiveKey;
extern NSString * const kMessageContentKey;
extern NSString * const kMessageTimeCreatedKey;
extern NSString * const kMessageUserSendIdKey;
extern NSString * const kMessageUserReceiveIdKey;
extern NSString * const kMessageStatusKey;
