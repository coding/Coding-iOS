//
//  MRPRDetailViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//
#import "BaseViewController.h"
#import "MRPRBaseInfo.h"
#import "Project.h"
@interface PRDetailViewController : BaseViewController
@property (strong, nonatomic) MRPR *curMRPR;
@property (strong, nonatomic) Project *curProject;//非必需
+ (PRDetailViewController *)vcWithPath:(NSString *)path;
- (void)refresh;
@end