//
//  TaskDescriptionCell.h
//  Coding_iOS
//
//  Created by Ease on 15/1/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"


@interface TaskDescriptionCell : UITableViewCell
- (void)setDescriptionStr:(NSString *)descriptionStr;

+ (CGFloat)cellHeight;
@end
