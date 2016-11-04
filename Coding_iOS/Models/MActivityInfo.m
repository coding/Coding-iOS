//
//  NSObject+MActivityInfo.m
//  Coding_iOS
//
//  Created by hardac on 16/3/26.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MActivityInfo.h"

@implementation MActivityInfo
- (void)setContent:(NSString *)content{
    if (_content != content) {
        _htmlMedia = [HtmlMedia htmlMediaWithString:content showType:MediaShowTypeNone];
        _content = _htmlMedia.contentDisplay;
    }
}
@end
