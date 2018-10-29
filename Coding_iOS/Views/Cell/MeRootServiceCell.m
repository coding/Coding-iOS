//
//  MeRootServiceCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeRootServiceCell.h"

@interface MeRootServiceCell ()
@property (strong, nonatomic) UILabel *leftL, *leftTL, *rightL, *rightTL;
@property (strong, nonatomic) UIView *lineV;
@property (strong, nonatomic) UIButton *leftBtn, *rightBtn;
@end

@implementation MeRootServiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_leftL) {
            _leftL = [UILabel labelWithFont:[UIFont systemFontOfSize:16] textColor:[UIColor colorWithHexString:@"0x323A45"]];
            [self.contentView addSubview:_leftL];
        }
        if (!_leftTL) {
            _leftTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
            _leftTL.text = @"项目数";
            [self.contentView addSubview:_leftTL];
        }
//        if (!_rightL) {
//            _rightL = [UILabel labelWithFont:[UIFont systemFontOfSize:16] textColor:[UIColor colorWithHexString:@"0x323A45"]];
//            [self.contentView addSubview:_rightL];
//        }
//        if (!_rightTL) {
//            _rightTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
//            _rightTL.text = @"公有";
//            [self.contentView addSubview:_rightTL];
//        }
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
//        if (!_rightBtn) {
//            _rightBtn = [UIButton new];
//            [_rightBtn bk_addEventHandler:^(id sender) {
//                if (weakSelf.rightBlock) {
//                    weakSelf.rightBlock();
//                }
//            } forControlEvents:UIControlEventTouchUpInside];
//            [self.contentView addSubview:_rightBtn];
//        }
//        [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self.contentView);
//            make.size.mas_equalTo(CGSizeMake(0.5, 40));
//        }];
        [_lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_right);
            make.size.mas_equalTo(CGSizeMake(0.5, 40));
        }];
        [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(self.contentView);
            make.right.equalTo(_lineV.mas_left);
        }];
//        [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.right.equalTo(self.contentView);
//            make.left.equalTo(_lineV.mas_right);
//        }];
        [_leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_leftBtn);
            make.top.equalTo(_leftBtn).offset(15);
        }];
        [_leftTL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_leftBtn);
            make.bottom.equalTo(_leftBtn).offset(-15);
        }];
//        [_rightL mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_rightBtn);
//            make.top.equalTo(_rightBtn).offset(15);
//        }];
//        [_rightTL mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_rightBtn);
//            make.bottom.equalTo(_rightBtn).offset(-15);
//        }];
    }
    return self;
}

- (void)setCurServiceInfo:(UserServiceInfo *)curServiceInfo{
    _curServiceInfo = curServiceInfo;
    _leftL.text = [NSString stringWithFormat:@"%@ / %@", _curServiceInfo.private ?: @"--", _curServiceInfo.private_project_quota ?: @"--"];
    _rightL.text = [NSString stringWithFormat:@"%@ / %@", _curServiceInfo.public ?: @"--", _curServiceInfo.public_project_quota ?: @"--"];
}

+ (CGFloat)cellHeight{
    return 75;
}
@end
