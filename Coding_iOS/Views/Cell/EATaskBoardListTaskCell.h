//
//  EATaskBoardListTaskCell.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface EATaskBoardListTaskCell : UITableViewCell

@property (strong, nonatomic) Task *task;

@property (copy, nonatomic) void(^taskStatusChangedBlock)(Task *task);

+ (CGFloat)cellHeightWithObj:(Task *)obj;

@end
