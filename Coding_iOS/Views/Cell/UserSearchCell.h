//
//  UserSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kUserSearchCellHeight 57

#import <UIKit/UIKit.h>
#import "User.h"
#import "Users.h"

@interface UserSearchCell : UITableViewCell
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) UsersType usersType;
@property (nonatomic,copy) void(^leftBtnClickedBlock)(User *curUser);

@property (assign, nonatomic) BOOL isInProject, isQuerying;


@end
