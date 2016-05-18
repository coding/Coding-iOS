//
//  MRPRListCell.h
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_MRPRListCell @"MRPRListCell"

#import <UIKit/UIKit.h>
#import "MRPR.h"

@interface MRPRListCell : UITableViewCell
@property (strong, nonatomic) MRPR *curMRPR;

+ (CGFloat)cellHeight;
@end
