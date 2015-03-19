//
//  TitleValueCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TitleValue @"TitleValueCell"

#import <UIKit/UIKit.h>

@interface TitleValueCell : UITableViewCell
- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value;
@end
