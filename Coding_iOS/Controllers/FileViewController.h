//
//  FileViewController.h
//  Coding_iOS
//
//  Created by Ease on 14/12/15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#import <QuickLook/QuickLook.h>
#import "BaseViewController.h"
#import "ProjectFolder.h"
#import "ProjectFolders.h"
#import "ProjectFile.h"

@interface FileViewController : BaseViewController
@property (strong, nonatomic) ProjectFile *curFile;
@end
