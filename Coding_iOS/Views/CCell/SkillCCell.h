//
//  SkillCCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/12/25.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCCellIdentifier_SkillCCell @"SkillCCell"

#import <UIKit/UIKit.h>
#import "CodingSkill.h"

@interface SkillCCell : UICollectionViewCell

@property (strong, nonatomic) CodingSkill *curSkill;
@property (copy, nonatomic) void(^deleteBlock)(CodingSkill *deletedSkill);

+ (CGSize)ccellSizeWithObj:(id)obj;
@end
