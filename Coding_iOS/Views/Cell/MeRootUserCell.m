//
//  MeRootUserCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeRootUserCell.h"

#ifdef Target_Enterprise

@interface MeRootUserCell ()
@property (strong, nonatomic) UIImageView *userV;
@property (strong, nonatomic) UILabel *userL, *gkL;
@end

@implementation MeRootUserCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_userV) {
            _userV = [YLImageView new];
            [_userV doCircleFrame];
            [_userV doBorderWidth:0.5 color:nil cornerRadius:25];
            [self.contentView addSubview:_userV];
        }
        if (!_userL) {
            _userL = [UILabel labelWithSystemFontSize:16 textColorHexString:@"0x1E2D42"];
            [self.contentView addSubview:_userL];
        }
        if (!_gkL) {
            _gkL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor colorWithHexString:@"0x1E2D42" andAlpha:0.6]];
            [self.contentView addSubview:_gkL];
        }
        [_userV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerY.equalTo(self.contentView);
        }];
        [_userL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userV);
            make.left.equalTo(_userV.mas_right).offset(15);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        [_gkL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userL.mas_bottom).offset(10);
            make.left.right.equalTo(_userL);
            make.height.mas_equalTo(20);
        }];
        
    }
    return self;
}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    
    [_userV sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResize:50* 2]];
    _userL.text = _curUser.name;
    _gkL.text = [NSString stringWithFormat:@"用户名：%@", _curUser.global_key];
}

+ (CGFloat)cellHeight{
    return 85;
}
@end

#else

@interface MeRootUserCell ()
@property (strong, nonatomic) UIImageView *userV, *vipV;
@property (strong, nonatomic) UILabel *userL, *vipL, *expirationL, *gkL;
@end

@implementation MeRootUserCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_userV) {
            _userV = [YLImageView new];
            [_userV doCircleFrame];
            [_userV doBorderWidth:0.5 color:nil cornerRadius:25];
            [self.contentView addSubview:_userV];
        }
        if (!_gkL) {
            _gkL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor colorWithHexString:@"0x1E2D42" andAlpha:0.6]];
            [self.contentView addSubview:_gkL];
        }
        if (!_vipV) {
            _vipV = [UIImageView new];
            [self.contentView addSubview:_vipV];
        }
        if (!_userL) {
            _userL = [UILabel labelWithSystemFontSize:16 textColorHexString:@"0x1E2D42"];
            [self.contentView addSubview:_userL];
        }
        if (!_vipL) {
            _vipL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColorDark7];
            _vipL.textAlignment = NSTextAlignmentCenter;
            _vipL.backgroundColor = kColorD8DDE4;
            _vipL.cornerRadius = 2;
            _vipL.masksToBounds = YES;
            [self.contentView addSubview:_vipL];
        }
        if (!_expirationL) {
            _expirationL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:kColorDark7];
            _expirationL.minimumScaleFactor = .5;
            _expirationL.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_expirationL];
        }
        [_userV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(50, 50));
            make.centerY.equalTo(self.contentView);
        }];
        [_vipV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_userV);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        [_userL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userV);
            make.left.equalTo(_userV.mas_right).offset(15);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        [_vipL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.left.equalTo(_userL);
            make.top.equalTo(_userL.mas_bottom).offset(10);
        }];
        [_expirationL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_vipL);
            make.left.equalTo(_vipL.mas_right).offset(8);
            make.right.equalTo(_userL);
        }];
        [_gkL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_userL.mas_bottom).offset(10);
            make.left.right.equalTo(_userL);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    
    [_userV sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResize:50* 2]];
    _userL.text = _curUser.name;
    _gkL.text = [NSString stringWithFormat:@"用户名：%@", _curUser.global_key];
    _vipL.hidden = _vipV.hidden = _expirationL.hidden = YES;
//    _vipV.image = [UIImage imageNamed:[NSString stringWithFormat:@"vip_%@_45", _curUser.vip]];
//    _vipL.text = _curUser.vipName;
//    NSString *expirationStr = [_curUser.vip_expired_at string_yyyy_MM_dd];
//
//    if (_curUser.vip.integerValue > 2) {
//        [_expirationL setAttrStrWithStr:[NSString stringWithFormat:@"到期时间：%@",expirationStr] diffColorStr:expirationStr diffColor:_curUser.willExpired? [UIColor colorWithHexString:@"0xF23524"]: kColorDark7];
//    }else{
//        _expirationL.hidden = YES;
//    }
}

+ (CGFloat)cellHeight{
    return 85;
}
@end

#endif
