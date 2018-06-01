//
//  FolderToMoveViewController.h
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectFile.h"
#import "Project.h"

@interface FolderToMoveViewController : BaseViewController
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) ProjectFile *curFolder, *fromFolder;
@property (strong, nonatomic) NSArray *toMovedIdList;
@property (assign, nonatomic) BOOL isMoveFolder;
@property (copy, nonatomic) void(^moveToFolderBlock)(ProjectFile *curFolder, NSArray *toMovedIdList);

@end
