//
//  FunctionTipsManager.h
//  Coding_iOS
//
//  Created by Ease on 15/6/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

////version: 3.0
//static NSString *kFunctionTipStr_MR = @"MergeRequest";
//static NSString *kFunctionTipStr_PR = @"PullRequest";
//static NSString *kFunctionTipStr_ReadMe = @"ReadMe";
//static NSString *kFunctionTipStr_CommitList = @"Code_CommitList";
////version: 3.1.5
//static NSString *kFunctionTipStr_Search = @"hasSearch";
//static NSString *kFunctionTipStr_HotTopic = @"HotTopic";
//static NSString *kFunctionTipStr_TweetTopic = @"TweetTopic";
////version: 3.2
//static NSString *kFunctionTipStr_VoiceMessage = @"VoiceMessage";
//static NSString *kFunctionTipStr_File_2V = @"File_2V";
//static NSString *kFunctionTipStr_File_2V_Version = @"File_2V_Version";
//static NSString *kFunctionTipStr_File_2V_Activity = @"File_2V_Activity";
//static NSString *kFunctionTipStr_LineNote_FileChange = @"LineNote_FileChange";
//static NSString *kFunctionTipStr_LineNote_MRPR = @"LineNote_MRPR";
//static NSString *kFunctionTipStr_Me_Points = @"Me_Points";
////version: 3.7
static NSString *kFunctionTipStr_StartLinkPrefix = @"StartLinkPrefix";
////version 4.0.8
//static NSString *kFunctionTipStr_File_3V = @"File_3V";
//version 4.5
static NSString *kFunctionTipStr_Me_Shop = @"Me_Shop";
//version 4.9.5
static NSString *kFunctionTipStr_TaskTitleViewTap = @"TaskTitleViewTap";


#import <Foundation/Foundation.h>

@interface FunctionTipsManager : NSObject
+ (instancetype)shareManager;

- (BOOL)needToTip:(NSString *)functionStr;
- (BOOL)markTiped:(NSString *)functionStr;

@end
