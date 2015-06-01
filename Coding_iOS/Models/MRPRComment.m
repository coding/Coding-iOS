//
//  MRPRComment.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRComment.h"
#import "MRPRCommentItem.h"

@implementation MRPRComment
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"MRPRCommentItem", @"items", nil];
    }
    return self;
}
@end
