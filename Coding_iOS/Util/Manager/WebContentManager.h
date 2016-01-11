//
//  WebContentManager.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeFile.h"

@interface WebContentManager : NSObject
+ (instancetype)sharedManager;
+ (NSString *)codePatternedWithContent:(CodeFile *)codeFile isEdit:(BOOL)isEdit;
+ (NSString *)bubblePatternedWithContent:(NSString *)content;
+ (NSString *)topicPatternedWithContent:(NSString *)content;
+ (NSString *)markdownPatternedWithContent:(NSString *)content;
+ (NSString *)diffPatternedWithContent:(NSString *)content andComments:(NSString *)comments;
@end
