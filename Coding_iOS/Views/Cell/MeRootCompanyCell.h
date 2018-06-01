//
//  MeRootCompanyCell.h
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2016/12/30.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_MeRootCompanyCell @"MeRootCompanyCell"

#import <UIKit/UIKit.h>
#import "Team.h"

@interface MeRootCompanyCell : UITableViewCell
@property (strong, nonatomic) Team *curCompany;
+ (CGFloat)cellHeight;
@end
