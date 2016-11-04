//
//  FileComment.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileComment.h"

@implementation FileComment
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
