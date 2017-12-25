//
//  SettingSkillsViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/12/25.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"

#import "CodingSkill.h"

@interface SettingSkillsViewController : BaseViewController

@property (copy, nonatomic) void(^doneBlock)(NSArray *selectedSkills);

+ (instancetype)settingSkillsVCWithDoneBlock:(void(^)(NSArray *selectedSkills))block;

@end
