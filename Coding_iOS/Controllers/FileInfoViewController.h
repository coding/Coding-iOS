//
//  FileInfoViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/8/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectFile.h"

@interface FileInfoViewController : BaseViewController
+ (instancetype)vcWithFile:(ProjectFile *)file;

@end
