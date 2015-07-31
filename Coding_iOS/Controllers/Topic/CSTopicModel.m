//
//  CSTopicModel.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSTopicModel.h"
#import "TMCacheExtend.h"

#define kLatestUseTopiclist @"com.cs.topic.uselist"
#define kMaxUseTopiclistCount 3

@implementation CSTopicModel

+ (NSArray*)latestUseTopiclist {
    NSArray *list = [[TMCache TemporaryCache] objectForKey:kLatestUseTopiclist];
    if (!list) {
        list = @[];
    }
    return list;
}

+ (void)addAnotherUseTopic:(NSString*)topicName {
    NSMutableArray *list = [[self latestUseTopiclist] mutableCopy];
    if(![list containsObject:topicName]) {
        [list insertObject:topicName atIndex:0];
        if(list.count > kMaxUseTopiclistCount) {
            [list removeLastObject];
        }
        [[TMCache TemporaryCache] setObject:list forKey:kLatestUseTopiclist];
    }
}

@end
