//
//  ShopOrderTextFieldCell.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ShopOrderTextFieldCell @"ShopOrderTextFieldCell"

#import <UIKit/UIKit.h>

@interface ShopOrderTextFieldCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UITextField *textField;

+ (CGFloat)cellHeight;

@end
