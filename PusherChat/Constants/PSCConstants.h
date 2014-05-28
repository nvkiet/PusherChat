//
//  PSCConstants.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/19/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PUSHER_API_KEY @"a303b94353376eae7485"
#define PUSHER_APP_ID  @"74518"
#define PUSHER_API_SECRET  @"43abb3c7a07e0b339e25"

#define FONT_HELVETICAL_REGULAR  @"HelveticaNeue"
#define FONT_HELVETICAL_LIGHT  @"HelveticaNeue-Light"


extern NSString * const kIsSender;

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
