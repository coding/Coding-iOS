//
//  NSObject+ReviewersInfo.m
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ReviewersInfo.h"

@implementation ReviewersInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Reviewer", @"reviewers", @"Reviewer",@"volunteer_reviewers",nil];
    }
    return self;
}

@end
