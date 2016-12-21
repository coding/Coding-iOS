//
//  FunctionTipsManager.m
//  Coding_iOS
//
//  Created by Ease on 15/6/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

static NSString *kFunctionTipStr_Version = @"version";

#import "FunctionTipsManager.h"

@interface FunctionTipsManager ()
@property (strong, nonatomic) NSMutableDictionary *tipsDict;
@end

@implementation FunctionTipsManager
+ (instancetype)shareManager{
    static FunctionTipsManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [[self alloc] init];
    });
    return shared_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tipsDict = [NSMutableDictionary dictionaryWithContentsOfFile:[self p_cacheFilePath]];
        if (![[_tipsDict valueForKey:@"version"] isEqualToString:kVersionBuild_Coding]) {
            _tipsDict = [@{kFunctionTipStr_Version: kVersionBuild_Coding,
                           //Function Need To Tip
//                           kFunctionTipStr_File_3V: @(YES),
                           } mutableCopy];
            [_tipsDict writeToFile:[self p_cacheFilePath] atomically:YES];
        }
    }
    return self;
}

- (NSString *)p_cacheFilePath{
    NSString *fileName = @"FunctionNeedTips.plist";
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths firstObject];
    return [cachePath stringByAppendingPathComponent:fileName];
}

- (BOOL)needToTip:(NSString *)functionStr{
    NSNumber *needToTip = [_tipsDict valueForKey:functionStr];
    if (!needToTip) {
        return [functionStr hasPrefix:kFunctionTipStr_StartLinkPrefix];
    }else{
        return needToTip.boolValue;
    }
}

- (BOOL)markTiped:(NSString *)functionStr{
    if (![self needToTip:functionStr]) {
        return NO;
    }
    [_tipsDict setValue:@(NO) forKey:functionStr];
    return [_tipsDict writeToFile:[self p_cacheFilePath] atomically:YES];
}

@end
