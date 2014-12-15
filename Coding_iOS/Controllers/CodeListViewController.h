//
//  CodeListViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/30.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectCodeListView.h"


@interface CodeListViewController : BaseViewController
@property (strong, nonatomic) Project *myProject;
@property (strong, nonatomic) CodeTree *myCodeTree;
@end
