//
//  TeamTopCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamTopCell.h"

@interface TeamTopCell ()
@property (strong, nonatomic) UIImageView *iconV;
@property (strong, nonatomic) UILabel *nameL, *introductionL;

@end

@implementation TeamTopCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorTableBG;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _iconV = [UIImageView new];
        [_iconV doBorderWidth:0 color:nil cornerRadius:2.0];
        _nameL = [UILabel labelWithSystemFontSize:15 textColorHexString:@"0x1E2D42"];
        _introductionL = [UILabel labelWithSystemFontSize:14 textColorHexString:@"0x999999"];
        //        _introductionL.numberOfLines = 0;
        for (UIView *subV in @[_iconV, _nameL, _introductionL]) {
            [self.contentView addSubview:subV];
        }
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.centerY.equalTo(self.contentView);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconV.mas_right).offset(15);
            make.top.equalTo(self.contentView).offset(15);
        }];
        [_introductionL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameL);
            make.bottom.equalTo(self.contentView).offset(-15);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        _iconV.image = [UIImage imageNamed:@"team_info_order"];
        _nameL.text = @"订单状态";
        
        _introductionL.minimumScaleFactor = 0.5;
        _introductionL.adjustsFontSizeToFitWidth = YES;
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setCurTeam:(Team *)curTeam{
    _curTeam = curTeam;
    
    BOOL isToped_up = [_curTeam.info isToped_up];//是否充值过
    BOOL isLocked = _curTeam.info.locked.boolValue;
    NSInteger remain_days = _curTeam.info.remain_days.integerValue;
    
    _introductionL.textColor = remain_days > kEANeedTipRemainDays? kColor999: kColorActionRed;
    NSString *valueStr = @"";
    if (!isToped_up) {
        valueStr = [NSString stringWithFormat:@"%ld", (long)[_curTeam.info trial_left_days]];
        if (!isLocked && valueStr.integerValue >= 0) {
            [_introductionL setAttrStrWithStr:[NSString stringWithFormat:@"试用期剩余 %@ 天", valueStr] diffColorStr:valueStr diffColor:valueStr.integerValue > kEANeedTipRemainDays? [UIColor colorWithHexString:@"0xF78636"]: kColorActionRed];
        }else{
            _introductionL.text = @"您的试用期已结束，请订购后使用";
        }
    }else{
        if (isLocked) {
            _introductionL.text = [NSString stringWithFormat:@"您的服务已暂停 %ld 天，请订购后使用", (long)[_curTeam.info stopped_days]];
        }else if (remain_days > kEANeedTipRemainDays) {
            valueStr = _curTeam.info.balance.stringValue;
            [_introductionL setAttrStrWithStr:[NSString stringWithFormat:@"账户余额：%@ 元", valueStr] diffColorStr:valueStr diffColor:[UIColor colorWithHexString:@"0xF78636"]];
        }else if (remain_days > 0){
            _introductionL.text = @"您的余额不足，请尽快订购";
        }else{
            _introductionL.text = [NSString stringWithFormat:@"您的服务已超时使用 %ld 天，请订购后使用", (long)[_curTeam.info beyond_days]];
        }
    }
}

+ (CGFloat)cellHeight{
    return 75;
}
@end
