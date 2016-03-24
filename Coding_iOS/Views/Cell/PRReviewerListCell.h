//
//  NSObject+PRReviewerListCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_PRReviewerListCell @"PRReviewerListCell"

#import <UIKit/UIKit.h>

@interface PRReviewerListCell : UITableViewCell
@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;

- (void)setImageStr:(NSArray *)reviewers;

- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;
- (void)addTipHeadIcon:(NSString *)IconString;

+ (CGFloat)cellHeight;

@end
