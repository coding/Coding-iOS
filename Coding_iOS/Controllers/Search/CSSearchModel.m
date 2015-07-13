//
//  CSSearchModel.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSSearchModel.h"
#import "TMCacheExtend.h"

#define kHasSearchBadgeShown @"com.cs.search.badge.hasShown"

@implementation CSSearchModel

+ (BOOL)hasSearchBadgeShown {
    BOOL hasShown = [[[TMCache TemporaryCache] objectForKey:kHasSearchBadgeShown] boolValue];
    return hasShown;
}

+ (void)invalidSearchBadge{
    [[TMCache TemporaryCache] setObject:@(YES) forKey:kHasSearchBadgeShown];
}


@end
