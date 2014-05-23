//
//  PSCChannelManager.m
//  PusherChat
//
//  Created by Kiet Nguyen on 5/23/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import "PSCChannelManager.h"

@implementation PSCChannelManager

+ (instancetype)shareInstance
{
    static PSCChannelManager *channelManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelManager = [[PSCChannelManager alloc] init];
    });
    return channelManager;
}

- (id)init
{
    self = [super init];
    if (self) {
         self.channelsArray = [NSMutableArray new];
    }
    return self;
}

- (void)addNewChannel:(PSCChannel *)theChannel
{
    if (![self getChannelByName:theChannel.channelName]) {
        NSLog(@"Channel Name: %@", theChannel.channelName);
        [self.channelsArray addObject:theChannel];
    }
}

- (PSCChannel *)getChannelByName:(NSString *)theChannelName
{
    for (PSCChannel *channel in self.channelsArray) {
        if ([channel.channelName isEqualToString: theChannelName]) {
            return channel;
        }
    }
    return nil;
}

- (void)unsubscribeAllChannels
{
    for (PSCChannel *channel in self.channelsArray) {
        [channel.presenceChannel unsubscribe];
    }
}

@end
