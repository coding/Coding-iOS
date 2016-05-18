//
//  TaskDescriptionViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/1/8.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Tasks.h"

@interface TaskDescriptionViewController : BaseViewController
@property (strong, nonatomic) Task *curTask;
@property (copy, nonatomic) void(^savedNewTDBlock)(Task_Description *taskD);

@end
