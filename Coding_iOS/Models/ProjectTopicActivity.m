//
//  ProjectTopicActivity.m
//  Coding_iOS
//
//  Created by Ease on 15/5/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTopicActivity.h"

@implementation ProjectTopicActivity
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeImageAndMonkey];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
