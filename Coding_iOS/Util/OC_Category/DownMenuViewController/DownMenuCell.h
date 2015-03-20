//
//  DownMenuCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_DownMenu @"DownMenuCell"

#import <UIKit/UIKit.h>
#import "UIDownMenuButton.h"

@interface DownMenuCell : UITableViewCell
@property (strong, nonatomic) DownMenuTitle *curItem;
@end
