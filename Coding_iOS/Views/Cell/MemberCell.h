//
//  MemberCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_MemberCell @"MemberCell"

#import <UIKit/UIKit.h>
#import "ProjectMember.h"
#import "ProjectMemberListViewController.h"
#import "SWTableViewCell.h"


@interface MemberCell : SWTableViewCell
@property (strong, nonatomic) ProjectMember *curMember;
@property (strong, nonatomic) UIButton *leftBtn;
@property (nonatomic,copy) void(^leftBtnClickedBlock)(id sender);
@property (assign, nonatomic) ProMemType type;

+ (CGFloat)cellHeight;
@end
