//
//  PSCChannelManager.h
//  PusherChat
//
//  Created by Kiet Nguyen on 5/23/14.
//  Copyright (c) 2014 Kiet Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  PSCChannel;

@interface PSCChannelManager : NSObject

@property (nonatomic, strong) NSMutableArray *channelsArray;

+ (instancetype)shareInstance;

- (void)addNewChannel:(PSCChannel *)theChannel;
- (PSCChannel *)getChannelByName:(NSString *)theChannelName;
- (void)unsubscribeAllChannels;

@end
