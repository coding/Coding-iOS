//
//  CodeFile.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"

@class CodeFile_RealFile;

@interface CodeFile : NSObject
@property (nonatomic, assign) BOOL can_edit, isHead;
@property (readwrite, nonatomic, strong) NSString *ref, *path;
@property (readwrite, nonatomic, strong) CodeFile_RealFile *file;
@property (strong, nonatomic) Commit *headCommit;
@property (strong, nonatomic) NSString *editData, *editMessage;

+ (CodeFile *)codeFileWithRef:(NSString *)ref andPath:(NSString *)path;
+ (CodeFile *)codeFileWithMDStr:(NSString *)md_html;
- (NSDictionary *)toEditParams;
@end


@interface CodeFile_RealFile : NSObject
@property (readwrite, nonatomic, strong) NSString *data, *lang, *lastCommitId, *lastCommitMessage, *mode, *name, *path, *preview;
@property (readwrite, nonatomic, strong) NSDate *lastCommitDate;
@property (readwrite, nonatomic, strong) Committer *lastCommitter;
@property (nonatomic, assign) BOOL previewed;
@property (nonatomic, assign) NSInteger size;
@end