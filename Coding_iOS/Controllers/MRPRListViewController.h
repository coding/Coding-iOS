//
//  MRPRListViewController.h
//  Coding_iOS
//
//  Created by Ease on 2017/2/14.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"

@interface MRPRListViewController : BaseViewController
@property (strong, nonatomic) Project *curProject;
@property (assign, nonatomic) BOOL isMR;
@end
