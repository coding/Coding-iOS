//
//  MeRootServiceCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeRootServiceCell.h"

@interface MeRootServiceCell ()
@property (strong, nonatomic) UILabel *proL, *proTL, *teamL, *teamTL;
@property (strong, nonatomic) UIView *lineV;
@property (strong, nonatomic) UIButton *leftBtn, *rightBtn;
@end

@implementation MeRootServiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_proL) {
            _proL = [UILabel labelWithFont:[UIFont boldSystemFontOfSize:20] textColor:[UIColor colorWithHexString:@"0x4F565F"]];
            [self.contentView addSubview:_proL];
        }
        if (!_proTL) {
            _proTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
            _proTL.text = @"项目";
            [self.contentView addSubview:_proTL];
        }
        if (!_teamL) {
            _teamL = [UILabel labelWithFont:[UIFont boldSystemFontOfSize:20] textColor:[UIColor colorWithHexString:@"0x4F565F"]];
            [self.contentView addSubview:_teamL];
        }
        if (!_teamTL) {
            _teamTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
            _teamTL.text = @"团队";
            [self.contentView addSubview:_teamTL];
        }
        if (!_lineV) {
            _lineV = [UIView new];
            _lineV.backgroundColor = kColorDDD;
            [self.contentView addSubview:_lineV];
        }
        ESWeak(self, weakSelf);
        if (!_leftBtn) {
            _leftBtn = [UIButton new];
            [_leftBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.leftBlock) {
                    weakSelf.leftBlock();
                }
            } forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_leftBtn];
        }
        if (!_rightBtn) {
            _rightBtn = [UIButton new];
            [_rightBtn bk_addEventHandler:^(id sender) {
                if (weakSelf.rightBlock) {
                    weakSelf.rightBlock();
                }
            } forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_rightBtn];
        }
        [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(0.5, 40));
        }];
        [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self.contentView);
            make.right.equalTo(_lineV.mas_left);
        }];
        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.equalTo(self.contentView);
            make.left.equalTo(_lineV.mas_right);
        }];
        [_proL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_lineV);
            make.baseline.equalTo(@[_proTL, _teamL, _teamTL]);
            make.right.equalTo(self.contentView.mas_right).multipliedBy(1.0/4);
        }];
        [_proTL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_proL.mas_right).offset(5);
        }];
        [_teamL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).multipliedBy(3.0/4);
        }];
        [_teamTL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_teamL.mas_right).offset(5);
        }];
    }
    return self;
}

- (void)setCurServiceInfo:(UserServiceInfo *)curServiceInfo{
    _curServiceInfo = curServiceInfo;
    _proL.text = _curServiceInfo? [NSString stringWithFormat:@"%ld", _curServiceInfo.private.integerValue + _curServiceInfo.public.integerValue]: @"--";
    _teamL.text = _curServiceInfo? _curServiceInfo.team.stringValue: @"--";
}

+ (CGFloat)cellHeight{
    return 75;
}
@end
