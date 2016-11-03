//
//  ProjectFolderListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "ProjectFolders.h"

@interface ProjectFolderListView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) UIViewController *containerVC;
@property (copy, nonatomic) void (^folderInProjectBlock)(ProjectFolders *, ProjectFolder *, Project *);
- (id)initWithFrame:(CGRect)frame project:(Project *)project;
- (void)reloadData;
- (void)refreshToQueryData;
@end
