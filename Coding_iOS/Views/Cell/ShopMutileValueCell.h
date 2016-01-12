//
//  ShopMutileValueCell.h
//  Coding_iOS
//
//  Created by Ease on 16/1/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_ShopMutileValueCell @"ShopMutileValueCell"

#import <UIKit/UIKit.h>

@interface ShopMutileValueCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *valueF;
@property (weak, nonatomic) IBOutlet UILabel *titleL;

+ (CGFloat)cellHeight;
@end
