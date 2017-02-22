//
//  NSObject+PRReviewerListCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/23.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_MRReviewerListCell @"PRReviewerListCell"

#import <UIKit/UIKit.h>

@interface MRReviewerListCell : UITableViewCell
@property (readwrite, nonatomic, strong) NSMutableArray *reviewers;
@property (copy, nonatomic) void(^lastItemClickedBlock)();

- (void)initCellWithReviewers:(NSArray *)reviewers;

- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;
- (void)addTipHeadIcon:(NSString *)IconString;

+ (CGFloat)cellHeight;

@end
