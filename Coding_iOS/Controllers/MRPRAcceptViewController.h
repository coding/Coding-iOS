//
//  MRPRAcceptViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"
#import "MRPRBaseInfo.h"

@interface MRPRAcceptViewController : BaseViewController
@property (strong, nonatomic) Project *curProject;
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
@property (nonatomic, copy) void(^completeBlock)(id data);
@end
