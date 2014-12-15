//
//  ProjectFiles.m
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "ProjectFiles.h"

@implementation ProjectFiles
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"ProjectFile", @"list", nil];
        _list = [NSMutableArray array];
        _isLoading = NO;
    }
    return self;
}
@end
