//
//  FileListViewController.h
//  Coding_iOS
//
//  Created by Ease on 14/11/14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "BaseViewController.h"
#import "ProjectFolder.h"
#import "ProjectFolders.h"

@interface FileListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) ProjectFolders *rootFolders;
@property (strong, nonatomic) ProjectFolder *curFolder;
@property (strong, nonatomic) Project *curProject;
@end
