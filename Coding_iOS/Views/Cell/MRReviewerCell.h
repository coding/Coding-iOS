//
//  NSObject+PRReviewerCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/22.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_MRReviewerCell @"PRReviewerCell"

#import <UIKit/UIKit.h>

@interface MRReviewerCell: UITableViewCell

- (void)setImageStr:(NSString *)imgStr
            isowner:(BOOL)ower
          hasLikeMr:(NSNumber *)hasLikeMr;
-(void) cantReviewer;
- (void)addTip:(NSString *)countStr;
- (void)addTipIcon;
- (void)removeTip;
- (void)addTipHeadIcon:(NSString *)IconString;

+ (CGFloat)cellHeight;

@end
