//
//  FileChangeDetailViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "MRPR.h"
#import "Project.h"

@interface FileChangeDetailViewController : BaseViewController
@property (strong, nonatomic) NSString *linkUrlStr;
@property (strong, nonatomic) NSString *noteable_id;

@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) NSString *commitId, *filePath;
@end
