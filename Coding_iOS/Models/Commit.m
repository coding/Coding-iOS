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
        contentStr = [NSString stringWithFormat:@"%@ : [%@] %@", _committer.name, [_sha substringToIndex:10], _short_message];
    }
    return contentStr;
}

- (void)setShort_message:(NSString *)short_message{
    if (short_message.length <= 0) {
        _short_message = short_message;
        return;
    }
    HtmlMedia *htmlHedia = [HtmlMedia htmlMediaWithString:short_message showType:MediaShowTypeNone];
    _short_message = htmlHedia.contentDisplay;
}

@end

@implementation Committer

@end
