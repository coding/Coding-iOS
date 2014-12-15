//
//  QcTask.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-22.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "QcTask.h"

@implementation QcTask

- (NSString *)link{
    return [NSString stringWithFormat:@"[%@]", [_link stringByRemoveHtmlTag]];
}

@end
