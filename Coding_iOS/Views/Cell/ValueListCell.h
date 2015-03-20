//
//  ValueListCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ValueList @"ValueListCell"

#import <UIKit/UIKit.h>

@interface ValueListCell : UITableViewCell
- (void)setTitleStr:(NSString *)title imageStr:(NSString *)imageName isSelected:(BOOL)selected;

@end
