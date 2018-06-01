//
//  TeamPurchaseTopCell.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_TeamPurchaseTopCell @"TeamPurchaseTopCell"

#import <UIKit/UIKit.h>
#import "Team.h"

@interface TeamPurchaseTopCell : UITableViewCell
@property (strong, nonatomic) Team *curTeam;
@property (copy, nonatomic) void (^closeWebTipBlock)();

+ (CGFloat)cellHeightWithObj:(id)obj;
@end
