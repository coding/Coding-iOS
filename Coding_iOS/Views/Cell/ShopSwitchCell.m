//
//  ShopSwitchCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2017/9/19.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "ShopSwitchCell.h"

@interface ShopSwitchCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentL;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;

@end

@implementation ShopSwitchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setShopGoods:(ShopGoods *)shopGoods{
    _shopGoods = shopGoods;
    [_mySwitch setOn:_shopGoods.usePoint];
    [self p_updateContentL];
}

- (void)p_updateContentL{
    CGFloat available_points = MIN(_shopGoods.available_points.floatValue, _shopGoods.points_cost.floatValue);
    _contentL.text = [NSString stringWithFormat:@"可用 %.2f 码币抵扣 %.2f 元", available_points, available_points* 50];
}

- (IBAction)valueChanged:(UISwitch *)sender {
    _shopGoods.usePoint = sender.isOn;
    [self p_updateContentL];
    if (_updateBlock) {
        _updateBlock();
    }
}
@end
