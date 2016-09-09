//
//  ProjectListViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Project_RootViewController.h"
#import "User.h"

@interface ProjectListViewController : Project_RootViewController
@property (strong, nonatomic) User *curUser;
@property (assign, nonatomic) BOOL isFromMeRoot;
@end
