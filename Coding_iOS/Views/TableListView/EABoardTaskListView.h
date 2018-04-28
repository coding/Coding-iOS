//
//  EABoardTaskListView.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EABoardTaskList.h"

@interface EABoardTaskListView : UIView
@property (strong, nonatomic) EABoardTaskList *myBoardTL;
@property (copy, nonatomic) void(^boardTLsChangedBlock)();

- (void)refresh;
@end
