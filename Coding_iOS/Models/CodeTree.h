//
//  CodeTree.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Commit.h"

@class CodeTree_File, CodeTree_CommitInfo;

@interface CodeTree : NSObject
@property (readwrite, nonatomic, strong) NSMutableArray *files, *commitInfos;
@property (nonatomic, assign) BOOL can_edit, isHead;
@property (readwrite, nonatomic, strong) Commit *lastCommit, *headCommit;
@property (strong, nonatomic) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSString *ref, *path;
@property (assign, nonatomic) BOOL isLoading;
@property (strong, nonatomic) NSArray *treeList;

- (void)configWithCommitInfos:(NSArray *)infos;
+ (CodeTree *)codeTreeMaster;
+ (CodeTree *)codeTreeWithRef:(NSString *)ref andPath:(NSString *)path;
@end

@interface CodeTree_File : NSObject
@property (readwrite, nonatomic, strong) NSString *mode, *name, *path;
@property (readwrite, nonatomic, strong) CodeTree_CommitInfo *info;
@end

@interface CodeTree_CommitInfo : NSObject
@property (readwrite, nonatomic, strong) NSDate *lastCommitDate;
@property (readwrite, nonatomic, strong) NSString *lastCommitId, *lastCommitMessage;
@property (readwrite, nonatomic, strong) NSString *mode, *name, *path;
@property (readwrite, nonatomic, strong) Committer *lastCommitter;
@property (readwrite, nonatomic, strong) NSString *submoduleLink, *submoduleUrl;
@end
