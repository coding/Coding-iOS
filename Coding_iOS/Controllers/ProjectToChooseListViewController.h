//
//  ProjectToChooseListViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/7/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"

@interface ProjectToChooseListViewController : BaseViewController
@property (copy, nonatomic) void(^projectChoosedBlock)(Project *project);
@end
