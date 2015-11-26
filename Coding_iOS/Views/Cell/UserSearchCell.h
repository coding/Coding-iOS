//
//  UserSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kUserSearchCellHeight 76

#import <UIKit/UIKit.h>
#import "User.h"
#import "Users.h"

@interface UserSearchCell : UITableViewCell
@property (strong, nonatomic) User *curUser;
@property (nonatomic,copy) void(^rightBtnClickedBlock)(User *curUser);
@property (assign, nonatomic) BOOL isInProject, isQuerying;
@end
