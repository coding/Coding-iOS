//
//  FileEditViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/8/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectFile.h"

@interface FileEditViewController : BaseViewController
@property (strong, nonatomic) ProjectFile *curFile;
@property (strong, nonatomic) void (^completeBlock)();

@end
