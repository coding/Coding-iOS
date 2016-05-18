//
//  ShopGoodsCCell.h
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCollectionCell.h"
@interface ShopGoodsCCell : BaseCollectionCell
{
    UIImageView *_coverView;
    
    UILabel     *_priceLabel;
    UILabel     *_titleLabel;
    
    UIButton    *_codingCoinView;
    UIImageView *_exchangeIconView;
}
@end
