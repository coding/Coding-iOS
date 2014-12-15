//
//  Commit.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Commit.h"

@implementation Commit
- (NSString *)contentStr{
    NSString *contentStr;
    if (_sha && _sha.length > 0) {
        contentStr = [NSString stringWithFormat:@"%@:[%@]%@", _committer.name, [_sha substringToIndex:7], _short_message];
    }
    return contentStr;
}
@end

@implementation Committer

@end