//
//  NSObject+PRReviewerCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/22.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_PRReviewerCell @"PRReviewerCell"

#import <UIKit/UIKit.h>

@interface PRReviewerCell: UITableViewCell

- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title;

- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;
- (void)addTipHeadIcon:(NSString *)IconString;

+ (CGFloat)cellHeight;

@end
