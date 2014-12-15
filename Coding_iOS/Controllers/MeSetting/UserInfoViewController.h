//
//  UserInfoViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "User.h"

@interface UserInfoViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) User *curUser;
@property (copy, nonatomic) void(^followChanged)(User *user);


@end
