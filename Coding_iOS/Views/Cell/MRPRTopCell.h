//
//  MRPRTopCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_MRPRTopCell @"MRPRTopCell"

#import <UIKit/UIKit.h>
#import "MRPRBaseInfo.h"
@class MRPRActionView;

@interface MRPRTopCell : UITableViewCell
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
+ (CGFloat)cellHeightWithObj:(id)obj;
@end


@interface MRPRActionView : UIView
- (void)setStatus:(MRPRStatus)status userName:(NSString *)userName actionDate:(NSDate *)actionDate;
@end