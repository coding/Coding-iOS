//
//  FolderToMoveViewController.h
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectFolder.h"
#import "ProjectFolders.h"
#import "ProjectFile.h"

@interface FolderToMoveViewController : BaseViewController

@property (strong, nonatomic) ProjectFolders *rootFolders;
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) ProjectFolder *curFolder, *fromFolder;
@property (strong, nonatomic) NSArray *toMovedIdList;
@property (assign, nonatomic) BOOL isMoveFolder;

@property (copy, nonatomic) void(^moveToFolderBlock)(ProjectFolder *curFolder, NSArray *toMovedIdList);

@end
