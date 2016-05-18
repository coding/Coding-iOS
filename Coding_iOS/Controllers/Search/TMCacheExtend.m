//
//  TMCacheExtend.m
//  IBY
//
//  Created by panshiyu on 15/5/8.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import "TMCacheExtend.h"

#define kTemporaryCache @"com.dv.cache.temporary"
#define kPermanentCache @"com.dv.cache.permanentCache"

@implementation TMCache (Extension)

+ (instancetype)TemporaryCache{
    return [[TMCache sharedCache] initWithName:kTemporaryCache];
}
+ (instancetype)PermanentCache {
    return [[TMCache sharedCache] initWithName:kPermanentCache];
}

@end
