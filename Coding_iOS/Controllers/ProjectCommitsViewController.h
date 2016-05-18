//
//  ProjectCommitsViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"
#import "Commits.h"

@interface ProjectCommitsViewController : BaseViewController
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) Commits *curCommits;

@end
