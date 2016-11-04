//
//  TaskComment.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TaskComment.h"

@implementation TaskComment
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
