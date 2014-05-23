//
//  PSCChannel.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/23/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChannel.h"

@implementation PSCChannel

- (PSCChannel *)initWithPresenceChannel:(PTPusherPresenceChannel *)thePresenceChannel andUserName:(NSString *)theChannelName anhUsersArray: (NSMutableArray *)theUsersArray
{
    self = [super init];
    if (self) {
        self.presenceChannel = thePresenceChannel;
        self.channelName = theChannelName;
        self.usersArray = theUsersArray;
    }
    return self;
}

@end
