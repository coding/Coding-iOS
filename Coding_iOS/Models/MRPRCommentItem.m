//
//  MRPRCommentItem.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRCommentItem.h"

@implementation MRPRCommentItem
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeCode];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
