//
//  NProjectItemCell.h
//  Coding_iOS
//
//  Created by Ease on 15/5/28.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_NProjectItemCell @"NProjectItemCell"

#import <UIKit/UIKit.h>

@interface NProjectItemCell : UITableViewCell
- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title;

- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;

+ (CGFloat)cellHeight;
@end
