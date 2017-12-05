//
//  ShopGoodsCCell.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopGoodsCCell.h"
#import "ShopGoods.h"

#define FONT(F) [UIFont systemFontOfSize:F]

@implementation ShopGoodsCCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self setUpContentView];
    }
    return self;
}


- (void)setUpContentView{
    
    UIView *superView = self.contentView;
    
    _coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.layer.masksToBounds =YES;
    [superView addSubview:_coverView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = FONT(14);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = kColor222;
    [superView addSubview:_titleLabel];
    
    _codingCoinView = [UIButton buttonWithType:UIButtonTypeCustom];
    _codingCoinView.userInteractionEnabled = NO;
    _codingCoinView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_codingCoinView setImage:[UIImage imageNamed:@"shop_coding_coin_icon"] forState:UIControlStateNormal];
    [_codingCoinView setTitle:@"  码币 " forState:UIControlStateNormal];
    [_codingCoinView setTitleColor:kColorDark7 forState:UIControlStateNormal];
    [_codingCoinView.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [superView addSubview:_codingCoinView];
    
    _exchangeIconView = [UIImageView new];
    _exchangeIconView.contentMode = UIViewContentModeScaleAspectFill;
    _exchangeIconView.clipsToBounds = YES;
    _exchangeIconView.backgroundColor = [UIColor clearColor];
    _exchangeIconView.image = [UIImage imageNamed:@"shop_exchange_icon"];

    [superView addSubview:_exchangeIconView];
    
    _priceLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:18] textColor:kColorBrandOrange];
    [superView addSubview:_priceLabel];
    
    _countLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColorDark7];
    [superView addSubview:_countLabel];
    
    float _coverViewHeight = self.frame.size.width * (176.0/284.0);
    NSLog(@"_coverViewHeight %lf",_coverViewHeight);
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(kPaddingLeftWidth);
        make.centerY.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView);
        make.left.equalTo(_coverView.mas_right).offset(20);
        make.right.equalTo(superView.mas_right).offset(-kPaddingLeftWidth);
    }];
    
    [_codingCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.centerY.equalTo(_coverView);
    }];
    
    [_exchangeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(superView).offset(-kPaddingLeftWidth);
        make.centerY.equalTo(_countLabel);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_titleLabel);
        make.bottom.equalTo(_coverView);
    }];
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_priceLabel.mas_right).offset(10);
        make.bottom.equalTo(_priceLabel);
    }];
}


- (void)configViewWithModel:(ShopGoods *)model
{
    [super configViewWithModel:model];
    
    _titleLabel.text = [model.name componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"¥￥"]].firstObject;
    NSString *points_cost = [NSString stringWithFormat:@"  %@ 码币", model.points_cost];
    [_codingCoinView setTitle:points_cost forState:UIControlStateNormal];
    
    CGFloat price = model.points_cost.floatValue * 50;
    if (price - ((int)price) < .1) {
        _priceLabel.text = [NSString stringWithFormat:@"￥%.0f", price];
    }else{
        _priceLabel.text = [NSString stringWithFormat:@"￥%.1f", price];
    }
    _countLabel.text = [NSString stringWithFormat:@"销量：%@", model.count];
    
    [self showExchangeIcon:model.exchangeable];
    
    [_coverView sd_setImageWithURL:[model.image urlImageWithCodePathResize:kScreen_Width] placeholderImage:nil];
}

- (void)showExchangeIcon:(BOOL)_isCanExchangeIcon
{
    _exchangeIconView.hidden = !_isCanExchangeIcon;
    
//    if (_isCanExchangeIcon) {
//        UIImage *image = [UIImage imageNamed:@"shop_exchange_icon"];
//        _exchangeIconView.image = image;
//    }else
//    {
//        UIImage *image = [UIImage imageNamed:@"shop_unexchange_icon"];
//        _exchangeIconView.image =image;
//    }
}


@end
