//
//  ShopGoodsInfoView.m
//  Coding_iOS
//
//  Created by liaoyp on 15/11/21.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ShopGoodsInfoView.h"
#import "DashesLineView.h"

#define FONT(F) [UIFont systemFontOfSize:F]

@interface ShopGoodsInfoView()
{
    UIImageView *_coverView;
    
    UILabel     *_priceLabel;
    UILabel     *_titleLabel;
    UILabel     *_descLabel;
    UILabel     *_countLabel;

    UIButton    *_codingCoinView;
}
@end

@implementation ShopGoodsInfoView

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
    UIView *superView = self;
    
    _coverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _coverView.backgroundColor = [UIColor colorWithHexString:@"0xe5e5e5"];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.layer.masksToBounds =YES;
    [superView addSubview:_coverView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = FONT(15);
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = kColor222;
    [superView addSubview:_titleLabel];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.numberOfLines = 0 ;
    _descLabel.backgroundColor = [UIColor clearColor];
    _descLabel.textColor = kColorDark7;
    [superView addSubview:_descLabel];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _countLabel.font = FONT(15);
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.text  = @"ⅹ1";
    _countLabel.textColor = kColorBrandGreen;
    [superView addSubview:_countLabel];
    
    _codingCoinView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_codingCoinView setImage:[UIImage imageNamed:@"shop_coding_coin_icon"] forState:UIControlStateNormal];
    [_codingCoinView setTitle:@"  码币 " forState:UIControlStateNormal];
    [_codingCoinView setTitleColor:kColorDark7 forState:UIControlStateNormal];
    [_codingCoinView.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [superView addSubview:_codingCoinView];
    

    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView).offset(15);
        make.left.equalTo(superView).offset(12);
        make.width.height.mas_equalTo(80);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView.mas_top);
        make.left.equalTo(_coverView.mas_right).offset(20);
        make.right.offset(-(20+13));
    }];
    
    [_countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_titleLabel.mas_centerY);
        make.right.equalTo(superView.mas_right).offset(-13);
        make.width.offset(20);
    }];
    
    [_codingCoinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_coverView);
//        make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        make.left.equalTo(_titleLabel.mas_left);
    }];
    
    DashesLineView *lineView = [[DashesLineView alloc] init];
    lineView.lineColor = kColorDDD;
    lineView.backgroundColor = [UIColor clearColor];
    [superView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView.mas_bottom).offset(15);
        make.left.equalTo(_coverView.mas_left);
        make.right.equalTo(superView.mas_right).offset(-12);
        make.height.offset(0.5);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.left.right.equalTo(lineView);
    }];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_coverView.mas_top).offset(-12);
        make.bottom.equalTo(_descLabel.mas_bottom).offset(12);
        make.width.offset(kScreen_Width);
    }];
    
    UIView *bottomLineView = [[UIView alloc] init];
    bottomLineView.backgroundColor = kColorDDD;
    [superView addSubview:bottomLineView];
    [bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
        make.left.right.bottom.equalTo(superView);
    }];
    
}

- (void)configViewWithModel:(ShopGoods *)model
{
    _titleLabel.text = model.name;
    NSString *points_cost = [NSString stringWithFormat:@"  %@ 码币",[model.points_cost stringValue]];
    [_codingCoinView setTitle:points_cost forState:UIControlStateNormal];
    
    
    [_coverView sd_setImageWithURL:[model.image urlImageWithCodePathResize:90* 2] placeholderImage:nil];
    
    HtmlMedia *mHtml = [[HtmlMedia alloc] initWithString:model.description_mine showType:MediaShowTypeNone];
    [_descLabel ea_setText:mHtml.contentDisplay lineSpacing:5];
//    _descLabel.text = mHtml.contentDisplay;
    
    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    self.frame = CGRectMake(0, 0, kScreen_Width, height);
    
}




@end
