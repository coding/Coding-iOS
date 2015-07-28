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
#define kSearchHistory @"com.cs.search.history"
#define kNewFeature @"com.cs.NewFeature"

@implementation CSSearchModel


+ (NSArray *)getSearchHistory {

    if(![[TMCache TemporaryCache] objectForKey:kSearchHistory]) {
    
        NSMutableArray *history = [[NSMutableArray alloc] initWithCapacity:3];
        [[TMCache TemporaryCache] setObject:history forKey:kSearchHistory];
    }
    
    return [[TMCache TemporaryCache] objectForKey:kSearchHistory];
}

+ (void)addSearchHistory:(NSString *)searchString {
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:[CSSearchModel getSearchHistory]];
    if(![history containsObject:searchString]) {
        if(history.count >= 8)
            [history removeLastObject];
        [history insertObject:searchString atIndex:0];
        [[TMCache TemporaryCache] setObject:history forKey:kSearchHistory];
    }
}

+ (void)cleanAllSearchHistory {

    NSMutableArray *history = [NSMutableArray arrayWithArray:[CSSearchModel getSearchHistory]];
    [history removeAllObjects];
    [[TMCache TemporaryCache] setObject:history forKey:kSearchHistory];
}


@end
