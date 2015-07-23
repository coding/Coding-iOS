//
//  FunctionTipsManager.h
//  Coding_iOS
//
//  Created by Ease on 15/6/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

//version: 3.0
static NSString *kFunctionTipStr_MR = @"MergeRequest";
static NSString *kFunctionTipStr_PR = @"PullRequest";
static NSString *kFunctionTipStr_ReadMe = @"ReadMe";
static NSString *kFunctionTipStr_CommitList = @"Code_CommitList";
static NSString *kFunctionTipStr_Search = @"hasSearch";
static NSString *kFunctionTipStr_HotTopic = @"HotTopic";
static NSString *kFunctionTipStr_TweetTopic = @"TweetTopic";

//CSSNewFeatureTypeTopic = 0,
//CSSNewFeatureTypeSearch,
//CSSNewFeatureTypeHotTopic

#import <Foundation/Foundation.h>

@interface FunctionTipsManager : NSObject
+ (instancetype)shareManager;

- (BOOL)needToTip:(NSString *)functionStr;
- (BOOL)markTiped:(NSString *)functionStr;

@end
