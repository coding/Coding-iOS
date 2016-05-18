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
        
        [self setUpContentView];
        
    }
    return self;
}


- (void)setUpContentView
{
//    self.contentView.backgroundColor = [UIColor whiteColor];
//    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    self.contentView.layer.borderWidth = 0.5;
    
    //float height = self.frame.size.width*((466.0/600.0));
    //    float height = (UIWidth - 30)/2;
    
    UIView *superView = self.contentView;
    
    _coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.layer.masksToBounds =YES;
    [superView addSubview:_coverView];
    
//    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    _priceLabel.font = FONT(12);
//    _priceLabel.backgroundColor = [UIColor clearColor];
//    _priceLabel.textColor = [UIColor colorWithHexString:@""];
//    [superView addSubview:_priceLabel];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = FONT(14);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
    [superView addSubview:_titleLabel];
    
    UIView *_coinView = [UIView new];
    [superView  addSubview: _coinView];
    
     _codingCoinView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_codingCoinView setImage:[UIImage imageNamed:@"shop_coding_coin_icon"] forState:UIControlStateNormal];
    [_codingCoinView setTitle:@"  码币 " forState:UIControlStateNormal];
    [_codingCoinView setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
    [_codingCoinView.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
    [_coinView addSubview:_codingCoinView];
    
    _exchangeIconView = [UIImageView new];
    _exchangeIconView.backgroundColor = [UIColor clearColor];
    [_coinView addSubview:_exchangeIconView];
    
    
    float _coverViewHeight = self.frame.size.width * (176.0/284.0);
    NSLog(@"_coverViewHeight %lf",_coverViewHeight);
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(superView);
        make.height.offset(_coverViewHeight);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView.mas_bottom).offset(10);
        make.left.equalTo(superView.mas_left).offset(10);
        make.right.equalTo(superView.mas_right).offset(-10);
    }];
    
    [_codingCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_coinView.mas_centerY);
        make.left.equalTo(_coinView.mas_left);
    }];
    
    [_exchangeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_coinView.mas_centerY);
        make.left.equalTo(_codingCoinView.mas_right).offset(10);
    }];
    
    [_coinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_codingCoinView.mas_left);
        make.right.equalTo(_exchangeIconView.mas_right);
        make.top.equalTo(_titleLabel.mas_bottom).offset(5);
        make.height.equalTo(@20);
        make.centerX.equalTo(_coverView.mas_centerX);
    }];
   
    
    
//
//    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_titleLabel.bottom).offset(5);
//        make.centerX.equalTo(_coverView.centerX);
//    }];
//    
//    
//    [_timeStampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(superView.left);
//        make.right.equalTo(superView.right);
//        make.bottom.equalTo(superView.bottom).offset(-5);
//    }];
    
}


- (void)configViewWithModel:(ShopGoods *)model
{
    [super configViewWithModel:model];
    
    _titleLabel.text = model.name;
    NSString *points_cost = [NSString stringWithFormat:@"  %@ 码币",[model.points_cost stringValue]];
    [_codingCoinView setTitle:points_cost forState:UIControlStateNormal];
    
    [self showExchangeIcon:model.exchangeable];
    
    [_coverView sd_setImageWithURL:[model.image urlWithCodePath] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (cacheType == SDImageCacheTypeNone) {
            [UIView transitionWithView:_coverView
                              duration:0.56
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                _coverView.image = image;
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
            
        }
    }];
    
}

- (void)showExchangeIcon:(BOOL)_isCanExchangeIcon
{
    if (_isCanExchangeIcon) {
        UIImage *image = [UIImage imageNamed:@"shop_exchange_icon"];
        _exchangeIconView.image = image;
    }else
    {
        UIImage *image = [UIImage imageNamed:@"shop_unexchange_icon"];
        _exchangeIconView.image =image;
    }
}


@end
