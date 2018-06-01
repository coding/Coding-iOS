//
//  TeamPurchaseOrderCell.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_TeamPurchaseOrderCell @"TeamPurchaseOrderCell"

#import <UIKit/UIKit.h>
#import "TeamPurchaseOrder.h"

@interface TeamPurchaseOrderCell : UITableViewCell
@property (strong, nonatomic) TeamPurchaseOrder *curOrder;

+ (CGFloat)cellHeight;
@end
