//
//  UserInfoViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/3/18.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "user.h"

@interface UserInfoViewController : BaseViewController
@property (strong, nonatomic) User *curUser;
@property (copy, nonatomic) void(^followChanged)(User *user);

@end
