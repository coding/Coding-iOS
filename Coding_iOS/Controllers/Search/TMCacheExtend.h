//
//  TMCacheExtend.h
//  IBY
//
//  Created by panshiyu on 15/5/8.
//  Copyright (c) 2015年 com.biyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCache.h"

@interface TMCache (Extension)

+ (instancetype)TemporaryCache;
+ (instancetype)PermanentCache;

@end
