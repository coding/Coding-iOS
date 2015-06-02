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
                             @"MRPRComment", @"discussions", nil];
    }
    return self;
}
@end
