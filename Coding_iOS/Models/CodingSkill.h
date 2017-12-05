//
//  CodingSkill.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/9/18.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodingSkill : NSObject
@property (strong, nonatomic) NSString *skillName;
@property (strong, nonatomic) NSNumber *skillId, *level;

@property (strong, nonatomic, readonly) NSString *skill_str;

+ (NSArray *)levelList;
@end
