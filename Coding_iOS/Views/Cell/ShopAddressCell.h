//
//  ShopAddressCell.h
//  Coding_iOS
//
//  Created by Ease on 16/1/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_ShopAddressCell @"ShopAddressCell"

#import <UIKit/UIKit.h>

@interface ShopAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *locationF;

+ (CGFloat)cellHeight;
@end
