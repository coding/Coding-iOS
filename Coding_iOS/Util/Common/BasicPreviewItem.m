//
//  BasicPreviewItem.m
//  Coding_iOS
//
//  Created by Ease on 14/11/20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BasicPreviewItem.h"

@implementation BasicPreviewItem
@synthesize previewItemTitle = _previewItemTitle;
@synthesize previewItemURL   = _previewItemURL;

+ (BasicPreviewItem *)itemWithUrl:(NSURL *)itemUrl{
    if (!itemUrl) {
        return nil;
    }
    NSString *itemTitle = itemUrl.absoluteString;
    itemTitle = [itemTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    itemTitle = [[itemTitle componentsSeparatedByString:@"/"] lastObject];
    itemTitle = [[itemTitle componentsSeparatedByString:@"|||"] firstObject];
    return [[BasicPreviewItem alloc] initWithUrl:itemUrl title:itemTitle];
}
- (instancetype)initWithUrl:(NSURL *)itemUrl title:(NSString *)title{
    self = [super init];
    if (self) {
        _previewItemURL = itemUrl;
        _previewItemTitle = title;
    }
    return self;
}

-(void)dealloc
{
    _previewItemURL = nil;
    _previewItemTitle = nil;
}
@end
