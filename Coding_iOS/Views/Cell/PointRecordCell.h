//
//  PointRecordCell.h
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_PointRecordCell @"PointRecordCell"

#import <UIKit/UIKit.h>
#import "PointRecord.h"

@interface PointRecordCell : UITableViewCell
@property (strong, nonatomic) PointRecord *curRecord;
+ (CGFloat)cellHeight;

@end
