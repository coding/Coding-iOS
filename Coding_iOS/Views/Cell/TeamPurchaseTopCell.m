//
//  TeamPurchaseTopCell.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2017/3/7.
//  Copyright © 2017年 Coding. All rights reserved.
//
#import "TeamPurchaseTopCell.h"

@interface TeamPurchaseTopCell ()
@property (strong, nonatomic) UILabel *tipL, *priceT, *priceV, *leftDayL;

@property (strong, nonatomic) UIView *toWebV;
@property (strong, nonatomic) UILabel *toWebL;
@property (strong, nonatomic) UIButton *toWebB;
@end

@implementation TeamPurchaseTopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _tipL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorActionRed];
        _priceT = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _priceV = [UILabel labelWithFont:[UIFont systemFontOfSize:30 weight:UIFontWeightMedium] textColor:kColorActionRed];
        _leftDayL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        _tipL.adjustsFontSizeToFitWidth = _leftDayL.adjustsFontSizeToFitWidth = YES;
        _tipL.minimumScaleFactor = _leftDayL.minimumScaleFactor = 0.5;
        [self.contentView addSubview:_tipL];
        [self.contentView addSubview:_priceT];
        [self.contentView addSubview:_priceV];
        [self.contentView addSubview:_leftDayL];
        
        [_leftDayL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.bottom.equalTo(self.contentView);
        }];
        [_priceV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_leftDayL.mas_top).offset(-10);
            make.height.mas_equalTo(42);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
        [_priceT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_priceV.mas_top).offset(-10);
            make.height.mas_equalTo(20);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
        [_tipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_priceT.mas_top).offset(-10);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
        _priceT.text = @"账户余额（元）";
        
        _toWebV = [UIView new];
        _toWebV.backgroundColor = [UIColor colorWithHexString:@"0xFAF7D4"];
        _toWebL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:[UIColor colorWithHexString:@"0xAE9651"]];
        _toWebB = [UIButton new];
        [_toWebV addSubview:_toWebL];
        [_toWebV addSubview:_toWebB];
        [self.contentView addSubview:_toWebV];
        
        [_toWebV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(44);
        }];
        [_toWebB mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.centerY.right.equalTo(_toWebV);
        }];
        [_toWebL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_toWebV);
            make.left.equalTo(_toWebV).offset(kPaddingLeftWidth);
            make.right.equalTo(_toWebB.mas_left);
        }];
        _toWebL.text = @"APP 暂不支持订购服务，请前往企业版网站订购";
        _toWebL.adjustsFontSizeToFitWidth = YES;
        _toWebL.minimumScaleFactor = 0.5;
        [_toWebB setImage:[UIImage imageNamed:@"btn_dismiss"] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_toWebB bk_addEventHandler:^(id sender) {
            if (weakSelf.closeWebTipBlock) {
                weakSelf.closeWebTipBlock();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        _tipL.minimumScaleFactor = 0.5;
        _tipL.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setCurTeam:(Team *)curTeam{
    _curTeam = curTeam;
    
    BOOL isToped_up = [_curTeam.info isToped_up];//是否充值过
    BOOL isTrial = _curTeam.info.trial.boolValue;
    BOOL isLocked = _curTeam.info.locked.boolValue;
    NSInteger remain_days = _curTeam.info.remain_days.integerValue;

    _tipL.textColor = remain_days > kEANeedTipRemainDays && !isLocked? kColorDark4: kColorActionRed;
    if (!isToped_up) {
        NSInteger trial_left_days = [_curTeam.info trial_left_days];
        if (isLocked || trial_left_days < 0) {
            _tipL.text = @"您的试用期已结束，请订购后使用";
        }else{
            _tipL.text = [NSString stringWithFormat:@"您正在试用 CODING 企业版，试用期剩余 %ld 天", (long)trial_left_days];
            if (remain_days > kEANeedTipRemainDays) {
                [_tipL setAttrStrWithStr:_tipL.text diffColorStr:@(trial_left_days).stringValue diffColor:[UIColor colorWithHexString:@"0xF78636"]];
            }
        }
    }else{
        if (isLocked) {
            _tipL.text = @"您的服务已过期，请订购后使用";
        }else if (remain_days > kEANeedTipRemainDays) {
            _tipL.text = nil;
        }else if (remain_days > 0){
            _tipL.text = @"您的账户余额不足，请尽快订购";
        }else{
            _tipL.text = @"您的服务已过期，请订购后使用";
        }
    }
    
    _priceT.hidden = _priceV.hidden = !isToped_up;
    _priceV.text = _curTeam.info.balance.stringValue;
    _priceV.textColor = (remain_days <= 0)? kColorActionRed: [UIColor colorWithHexString:@"0xF78636"];
    
    if (_priceT.hidden) {
        [_tipL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_leftDayL.mas_top).offset(-10);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
    }else{
        [_tipL mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_priceT.mas_top).offset(-10);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
    }
    
    if (isLocked) {
        NSInteger stopped_days = [_curTeam.info stopped_days];
        _leftDayL.text = [NSString stringWithFormat:@"服务已暂停 %ld 天。", (long)stopped_days];
    }else if (isTrial && !isToped_up){
        _leftDayL.text = [NSString stringWithFormat:@"试用期至 %@", [_curTeam.info.estimate_date stringWithFormat:@"yyyy 年 MM 月 dd 日"]];
    }else{
        if (remain_days > 0) {
            _leftDayL.text = [NSString stringWithFormat:@"余额预计可使用至 %@，剩余 %ld 天。", [_curTeam.info.estimate_date stringWithFormat:@"yyyy 年 MM 月 dd 日"], (long)remain_days];
        }else{
            NSInteger beyond_days = [_curTeam.info beyond_days];
            _leftDayL.text = [NSString stringWithFormat:@"过期时间 %@，已超时使用 %ld 天。", [_curTeam.info.estimate_date stringWithFormat:@"yyyy 年 MM 月 dd 日"], (long)beyond_days];
        }
    }
    BOOL needWebTip = (isLocked ||
                       (!isTrial && remain_days <= kEANeedTipRemainDays));
    needWebTip = needWebTip && !_curTeam.hasDismissWebTip;
    _toWebV.hidden = !needWebTip;
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Team class]]) {
        Team *curTeam = (Team *)obj;
        BOOL isToped_up = [curTeam.info isToped_up];//是否充值过
        BOOL isTrial = curTeam.info.trial.boolValue;
        BOOL isLocked = curTeam.info.locked.boolValue;
        NSInteger remain_days = curTeam.info.remain_days.integerValue;
        
        if (!isToped_up) {
            cellHeight = 85;
        }else{
            BOOL needTipStr = (!isToped_up || remain_days <= kEANeedTipRemainDays || isLocked);
            if (needTipStr) {
                cellHeight = 165;
            }else{
                cellHeight = 132;
            }
        }
        BOOL needWebTip = (isLocked ||
                           (!isTrial && remain_days <= kEANeedTipRemainDays));
        needWebTip = needWebTip && !curTeam.hasDismissWebTip;
        cellHeight += needWebTip? 44: 0;
    }
    return cellHeight;
}
@end
