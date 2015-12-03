//
//  TaskSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskSearchCell : UITableViewCell
@property (strong, nonatomic) Task *task;
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
