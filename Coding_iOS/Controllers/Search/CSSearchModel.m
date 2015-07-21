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

+ (BOOL)hasClickedNewFeatureWithType:(CSSNewFeatureType)type {

    NSString *key = [kNewFeature stringByAppendingString:[NSString stringWithFormat:@"_%ld", (long)type]];
    id hasClicked = [[TMCache TemporaryCache] objectForKey:key];
    if(!hasClicked) {
    
        [[TMCache TemporaryCache] setObject:@(NO) forKey:key];
    }else {
    
        return [hasClicked boolValue];
    }
    return NO;
}

+ (void)clickNewFeatureWithType:(CSSNewFeatureType)type {

     NSString *key = [kNewFeature stringByAppendingString:[NSString stringWithFormat:@"_%ld", (long)type]];
    [[TMCache TemporaryCache] setObject:@(YES) forKey:key];
}

+ (BOOL)hasSearchBadgeShown {
    BOOL hasShown = [[[TMCache TemporaryCache] objectForKey:kHasSearchBadgeShown] boolValue];
    return hasShown;
}

+ (void)invalidSearchBadge{
    [[TMCache TemporaryCache] setObject:@(YES) forKey:kHasSearchBadgeShown];
}

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
        if(history.count >= 3)
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
