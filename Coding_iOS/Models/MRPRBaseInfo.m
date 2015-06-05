//
//  MRPRBaseInfo.m
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRBaseInfo.h"

@implementation MRPRBaseInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectLineNote", @"discussions", nil];
        _contentHeight = 1;
    }
    return self;
}
- (MRPR *)mrpr{
    if (_pull_request) {
        return _pull_request;
    }else{
        return _merge_request;
    }
}

- (void)setPull_request_description:(NSString *)pull_request_description{
    if (pull_request_description.length <= 0) {
        pull_request_description = @"没有填写内容";
    }
    _htmlMedia = [HtmlMedia htmlMediaWithString:pull_request_description showType:MediaShowTypeCode];
    _pull_request_description = _htmlMedia.contentDisplay;
}

- (void)setMerge_request_description:(NSString *)merge_request_description{
    if (merge_request_description.length <= 0) {
        merge_request_description = @"没有填写内容";
    }
    _htmlMedia = [HtmlMedia htmlMediaWithString:merge_request_description showType:MediaShowTypeCode];
    _merge_request_description = _htmlMedia.contentDisplay;
}
@end
