//
//  CodeTree.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CodeTree_Committer, CodeTree_LastCommit, CodeTree_File, CodeTree_CommitInfo;

@interface CodeTree : NSObject
@property (readwrite, nonatomic, strong) NSMutableArray *files, *commitInfos;
@property (nonatomic, assign) BOOL can_edit, isHead;
@property (readwrite, nonatomic, strong) CodeTree_LastCommit *lastCommit;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSString *ref, *path;
@property (assign, nonatomic) BOOL isLoading;
- (void)configWithCommitInfos:(NSArray *)infos;
+ (CodeTree *)codeTreeMaster;
+ (CodeTree *)codeTreeWithRef:(NSString *)ref andPath:(NSString *)path;
@end

@interface CodeTree_LastCommit : NSObject
@property (readwrite, nonatomic, strong) NSString *commitId, *fullMessage, *shortMessage;
@property (strong, nonatomic) NSDate *commitTime;
@property (readwrite, nonatomic, strong) CodeTree_Committer *committer;
@end

@interface CodeTree_Committer : NSObject
@property (readwrite, nonatomic, strong) NSString *avatar, *name, *link, *email;
@end

@interface CodeTree_File : NSObject
@property (readwrite, nonatomic, strong) NSString *mode, *name, *path;
@property (readwrite, nonatomic, strong) CodeTree_CommitInfo *info;
@end

@interface CodeTree_CommitInfo : NSObject
@property (readwrite, nonatomic, strong) NSDate *lastCommitDate;
@property (readwrite, nonatomic, strong) NSString *lastCommitId, *lastCommitMessage;
@property (readwrite, nonatomic, strong) NSString *mode, *name, *path;
@property (readwrite, nonatomic, strong) CodeTree_Committer *lastCommitter;
@end