//
//  TeamPurchaseBillingCell.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "TeamPurchaseBillingCell.h"

@interface TeamPurchaseBillingCell ()
@property (strong, nonatomic) UILabel *createAtL, *statusL;
@property (strong, nonatomic) UILabel *useageT, *priceT, *priceV, *balanceT, *balanceV;
@property (strong, nonatomic) NSMutableArray *detailsL;
@property (strong, nonatomic) UIButton *expandBtn;
@end

@implementation TeamPurchaseBillingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _createAtL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark3];
        _statusL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDarkA];
        _useageT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _priceT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _priceV = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _balanceT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _balanceV = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _expandBtn = [UIButton new];
        [self.contentView addSubview:_createAtL];
        [self.contentView addSubview:_statusL];
        [self.contentView addSubview:_useageT];
        [self.contentView addSubview:_priceT];
        [self.contentView addSubview:_priceV];
        [self.contentView addSubview:_balanceT];
        [self.contentView addSubview:_balanceV];
        [self.contentView addSubview:_expandBtn];
        UIView *lineV = ({
            UIView *view = [UIView new];
            view.backgroundColor = kColorDarkD;
            [self.contentView addSubview:view];
            view;
        });
        UIView *bottomV = ({
            UIView *view = [UIView new];
            view.backgroundColor = kColorDarkF;
            [self.contentView addSubview:view];
            view;
        });
        CGFloat labelW = 240;
        CGFloat pointX = kScreen_Width - kPaddingLeftWidth - labelW;
        _createAtL.frame = CGRectMake(kPaddingLeftWidth, 10, labelW, 20);
        _statusL.frame = CGRectMake(pointX, 10, labelW, 20);
        _useageT.frame = CGRectMake(kPaddingLeftWidth, 50, labelW, 20);
        lineV.frame = CGRectMake(kPaddingLeftWidth, 40, kScreen_Width, 1.0/[UIScreen mainScreen].scale);
        bottomV.frame = CGRectMake(0, 140, kScreen_Width, 10);
        [bottomV addLineUp:YES andDown:NO];
        
        [bottomV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.mas_equalTo(10);
        }];
        [_balanceT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(bottomV.mas_top).offset(-10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        [_balanceV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(_balanceT);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        [_priceT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_balanceT.mas_top).offset(-10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        [_priceV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.height.equalTo(_priceT);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        [_expandBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_priceV.mas_top).offset(-10);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(200, 20));
        }];
        
        _statusL.textAlignment = NSTextAlignmentRight;
        _priceV.textAlignment = NSTextAlignmentRight;
        _balanceV.textAlignment = NSTextAlignmentRight;
        
//        _useageT.text = @"使用情况";
//        _priceT.text = @"结算金额";
//        _balanceT.text = @"剩余金额";
        
        _useageT.text = @"当日使用情况";
        _priceT.text = @"扣款时间";
        _balanceT.text = @"扣款金额";

        _detailsL = @[].mutableCopy;
        
        [_expandBtn setTitleColor:kColorLightBlue forState:UIControlStateNormal];
        _expandBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _expandBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_expandBtn setTitle:@"查看全部" forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_expandBtn bk_addEventHandler:^(id sender) {
            if (weakSelf.expandBlock) {
                weakSelf.expandBlock(weakSelf.curBilling);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setCurBilling:(TeamPurchaseBilling *)curBilling{
    _curBilling = curBilling;
    
//    _createAtL.text = [_curBilling.created_at stringWithFormat:@"MM 月（结算日：yyyy.MM.dd）"];
//    _statusL.text = @"已结算";//To Dooooooooooo
//    _priceV.text = [NSString stringWithFormat:@"￥ %@", _curBilling.price];
//    _balanceV.text = [NSString stringWithFormat:@"￥ %@", _curBilling.balance];

    _createAtL.text = [_curBilling.billing_date stringWithFormat:@"结算日：yyyy.MM.dd"];
    _statusL.hidden = YES;
    _priceV.text = [_curBilling.created_at stringWithFormat:@"yyyy.MM.dd HH:mm"];
    _balanceV.text = [NSString stringWithFormat:@"￥ %@", _curBilling.price];
    
    [_detailsL makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_detailsL removeAllObjects];
    NSInteger detailNum = _curBilling.isExpanded? _curBilling.details_display.count: MIN(_curBilling.details_display.count, 2);
    for (NSInteger index = 0; index < detailNum; index++) {
        [self addIndex:index detail:_curBilling.details_display[index]];
    }
    _expandBtn.hidden = (_curBilling.details_display.count <= detailNum);
}

- (void)addIndex:(NSInteger)index detail:(NSString *)detail_display{
    UILabel *detailL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
    detailL.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth - 200, 50 + (30 * index), 200, 20);
    detailL.textAlignment = NSTextAlignmentRight;
    detailL.text = detail_display;
    [_detailsL addObject:detailL];
    [self.contentView addSubview:detailL];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    if ([obj isKindOfClass:[TeamPurchaseBilling class]]) {
        TeamPurchaseBilling *billing = (TeamPurchaseBilling *)obj;
        NSInteger detailNum = billing.isExpanded? billing.details_display.count: MIN(billing.details_display.count, 3);
        CGFloat cellHeight = 150;
        cellHeight += 30 * (detailNum - 1);
        return cellHeight;
    }
    return 0;
}
@end
