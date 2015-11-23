//
//  PointRecord.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecord.h"

@implementation PointRecord
- (void)setUsage:(NSString *)usage{
    _htmlMedia = [HtmlMedia htmlMediaWithString:usage showType:MediaShowTypeAll];
    _usage = _htmlMedia.contentDisplay;
}
@end
