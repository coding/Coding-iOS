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
+ (NSString *)bubblePatternedWithContent:(NSString *)content;
+ (NSString *)topicPatternedWithContent:(NSString *)content;
+ (NSString *)codePatternedWithContent:(CodeFile *)codeFile;
+ (NSString *)markdownPatternedWithContent:(NSString *)content;
@end
