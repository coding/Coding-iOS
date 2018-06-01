//
//  TeamPurchaseBillingCell.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_TeamPurchaseBillingCell @"TeamPurchaseBillingCell"

#import <UIKit/UIKit.h>
#import "TeamPurchaseBilling.h"

@interface TeamPurchaseBillingCell : UITableViewCell
@property (strong, nonatomic) TeamPurchaseBilling *curBilling;
@property (copy, nonatomic) void (^expandBlock)(TeamPurchaseBilling *curBilling);

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
