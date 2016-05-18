//
//  FileChange.m
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileChange.h"

@interface FileChange ()
@property (readwrite, strong, nonatomic) NSString *displayFilePath, *displayFileName;
@end

@implementation FileChange
- (void)setPath:(NSString *)path{
    _path = path;
    NSRange range = [_path rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        _displayFilePath = @"/";
        _displayFileName = _path;
    }else{
        _displayFilePath = [_path substringToIndex:range.location +1];
        _displayFileName = [_path substringFromIndex:range.location +1];
    }
}
- (NSString *)displayFileName{
    return _displayFileName? _displayFileName: @"...";
}
- (NSString *)displayFilePath{
    return _displayFilePath? _displayFilePath: @"/";
}
@end
