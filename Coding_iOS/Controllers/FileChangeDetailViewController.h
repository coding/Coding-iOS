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
@property (strong, nonatomic) NSString *requestPath;
@property (strong, nonatomic) NSDictionary *requestParams;

@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) NSString *filePath;//为了标题
@end
