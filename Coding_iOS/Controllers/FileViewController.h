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
#import "FileVersion.h"

@interface FileViewController : BaseViewController
@property (strong, nonatomic, readonly) ProjectFile *curFile;
@property (strong, nonatomic, readonly) FileVersion *curVersion;
+ (instancetype)vcWithFile:(ProjectFile *)file andVersion:(FileVersion *)version;
- (void)requestFileData;
@property (copy, nonatomic) void (^fileHasBeenDeletedBlock)();
@property (copy, nonatomic) void (^fileHasChangedBlock)();

@end
