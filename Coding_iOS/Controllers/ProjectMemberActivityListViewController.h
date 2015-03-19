//
//  ProjectMemberActivityListViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectActivityListView.h"

@interface ProjectMemberActivityListViewController : BaseViewController
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) User *curUser;
@end
