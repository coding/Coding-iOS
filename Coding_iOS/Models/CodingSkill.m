//
//  CodingSkill.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/9/18.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "CodingSkill.h"

@implementation CodingSkill

- (NSString *)skill_str{
    NSInteger level = MIN([CodingSkill levelList].count, MAX(0, _level.integerValue - 1));
    return [NSString stringWithFormat:@"%@·%@", _skillName, [CodingSkill levelList][level]];
}

+ (NSArray *)levelList{
    return @[@"入门", @"一般", @"熟练", @"精通", ];
}

@end
