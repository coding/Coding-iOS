//
//  CommitInfo.m
//  Coding_iOS
//
//  Created by Ease on 15/6/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CommitInfo.h"

@implementation CommitInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectLineNote", @"commitComments", nil];
    }
    return self;
}
@end
