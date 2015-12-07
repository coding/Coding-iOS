//
//  ShopOrderListView.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShopOrderModel.h"

@interface ShopOrderListView : UIView

@property (nonatomic, strong) ShopOrderModel *myOrder;
- (instancetype)initWithFrame:(CGRect)frame withOder:(ShopOrderModel *)order;

- (void)reloadData;

@end

