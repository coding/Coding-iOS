//
//  CodeTree.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodeTree.h"

@implementation CodeTree
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"CodeTree_File", @"files", nil];
        _commitInfos = nil;
        _isLoading = NO;
    }
    return self;
}
+ (CodeTree *)codeTreeMaster{
    return [CodeTree codeTreeWithRef:@"master" andPath:@""];
}
+ (CodeTree *)codeTreeWithRef:(NSString *)ref andPath:(NSString *)path{
    CodeTree *codeTree = [[CodeTree alloc] init];
    codeTree.ref = ref.length > 0? ref: @"master";
    codeTree.path = path;
    return codeTree;
}
- (NSString *)path{
    if (!_path) {
        _path = @"";
    }
    return _path;
}
- (NSString *)ref{
    if (!_ref) {
        _ref = @"master";
    }
    return _ref;
}
- (void)configWithCommitInfos:(NSArray *)infos{
    if (!infos || infos.count <= 0) {
        return;
    }
    if (!self.files || self.files.count <= 0) {
        return;
    }
    for (CodeTree_File *file in self.files) {
        for (CodeTree_CommitInfo *info in infos) {
            if ([file.path isEqualToString:info.path]) {
                file.info = info;
            }
        }
    }
}
@end

@implementation CodeTree_File
- (NSString *)mode{
    if (!_mode) {
        _mode = @"";
    }
    return _mode;
}
@end

@implementation CodeTree_CommitInfo

@end
