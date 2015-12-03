//
//  UserCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_UserCell @"UserCell"

#import <UIKit/UIKit.h>
#import "User.h"
#import "Users.h"

@interface UserCell : UITableViewCell
@property (strong, nonatomic) UIImageView *userIconView;

@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) UsersType usersType;
@property (nonatomic,copy) void(^leftBtnClickedBlock)(User *curUser);

@property (assign, nonatomic) BOOL isInProject, isQuerying;

+ (CGFloat)cellHeight;
@end
