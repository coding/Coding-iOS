//
//  ProjectTag.m
//  Coding_iOS
//
//  Created by Ease on 15/7/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ProjectTag.h"
#import "Login.h"

@implementation ProjectTag

- (instancetype)init
{
    self = [super init];
    if (self) {
        _id = @(0);
        _count = @(0);
        _owner_id = [Login curLoginUser].id;
        _name = @"";
        _color = [NSString stringWithFormat:@"#%@", [[UIColor randomColor] hexStringFromColor]];
    }
    return self;
}

+ (instancetype)tagWithName:(NSString *)name{
    ProjectTag *tag = [[self alloc] init];
    tag.name = name;
    return tag;
}

@end