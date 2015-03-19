//
//  TitleValueMoreCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-3.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_TitleValueMore @"TitleValueMoreCell"

#import <UIKit/UIKit.h>

@interface TitleValueMoreCell : UITableViewCell
- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value;
+ (CGFloat)cellHeight;
@end
