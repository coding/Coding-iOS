//
//  MRPRFilesViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "MRPR.h"
#import "FileChanges.h"
#import "Project.h"
#import "MRPRBaseInfo.h"

@interface MRPRFilesViewController : BaseViewController
@property (strong, nonatomic) MRPR *curMRPR;
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
@property (strong, nonatomic) Project *curProject;

@end
