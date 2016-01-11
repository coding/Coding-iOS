//
//  CodeFile.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodeFile.h"

@implementation CodeFile

+ (CodeFile *)codeFileWithRef:(NSString *)ref andPath:(NSString *)path{
    CodeFile *codeFile = [[CodeFile alloc] init];
    codeFile.ref = ref;
    codeFile.path = path;
    return codeFile;
}
+ (CodeFile *)codeFileWithMDStr:(NSString *)md_html{
    CodeFile *codeFile = [self codeFileWithRef:@"" andPath:@"README"];
    
    CodeFile_RealFile *file = [CodeFile_RealFile new];
    file.mode = @"file";
    file.lang = @"markdown";
    file.preview = md_html;
    
    codeFile.file = file;
    return codeFile;
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
- (NSString *)editData{
    if (!_editData) {
        _editData = _file.data.copy;
    }
    return _editData;
}
- (NSString *)editMessage{
    if (!_editMessage) {
        _editMessage = [NSString stringWithFormat:@"update %@", _path];
    }
    return _editMessage;
}
- (NSDictionary *)toEditParams{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"content"] = self.editData;
    params[@"message"] = self.editMessage;
    params[@"lastCommitSha"] = self.headCommit.commitId;
    return params;
}
@end


@implementation CodeFile_RealFile

@end