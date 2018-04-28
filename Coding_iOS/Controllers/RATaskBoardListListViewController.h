//
//  RATaskBoardListListViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectViewController.h"
#import "EABoardTaskList.h"

@interface RATaskBoardListListViewController : BaseViewController
@property (strong, nonatomic) Project *curPro;
@property (strong, nonatomic) EABoardTaskList *selectedBoardTL;
@property (assign, nonatomic) BOOL needToShowDoneBoardTL;
@property (copy, nonatomic) void(^selectedBlock)(EABoardTaskList *selectedBoardTL);
@end
