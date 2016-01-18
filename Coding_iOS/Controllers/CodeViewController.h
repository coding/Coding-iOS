//
//  CodeViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"
#import "CodeFile.h"

@interface CodeViewController : BaseViewController<UIWebViewDelegate>
@property (strong, nonatomic) Project *myProject;
@property (strong, nonatomic) CodeFile *myCodeFile;
@property (assign, nonatomic) BOOL isReadMe;
+ (CodeViewController *)codeVCWithProject:(Project *)project andCodeFile:(CodeFile *)codeFile;
@end
