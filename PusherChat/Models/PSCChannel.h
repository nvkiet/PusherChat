//
//  PSCChannel.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/23/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSCChannel : NSObject

@property (nonatomic, strong) PTPusherPresenceChannel *presenceChannel;
@property (nonatomic, strong) NSString *channelName;
@property (nonatomic, strong) NSMutableArray *usersArray;
@property (nonatomic, strong) NSMutableArray *messagesArray;

- (PSCChannel *)initChannelWithPresenceChannel:(PTPusherPresenceChannel *)thePresenceChannel andUserName:(NSString *)theChannelName anhUsersArray: (NSMutableArray *)theUsersArray;

@end
