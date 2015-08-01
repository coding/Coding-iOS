//
//  ResetLabelViewController.h
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@class ProjectTag;
@class Project;
@interface ResetLabelViewController : BaseViewController

@property (weak, nonatomic) ProjectTag *ptLabel;
@property (strong, nonatomic) Project *curProject;

@end
