//
//  TeamMemberCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TeamMemberCell @"TeamMemberCell"

#import <UIKit/UIKit.h>
#import "TeamMember.h"
#import "SWTableViewCell.h"


@interface TeamMemberCell : SWTableViewCell
@property (strong, nonatomic) TeamMember *curMember;

+ (CGFloat)cellHeight;

@end
