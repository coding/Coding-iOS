//
//  MRPRCommitsViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "MRPR.h"
#import "Commit.h"
#import "Project.h"

@interface MRPRCommitsViewController : BaseViewController
@property (strong, nonatomic) MRPR *curMRPR;
@property (strong, nonatomic) Project *curProject;

@end
