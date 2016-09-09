//
//  MeRootUserCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeRootUserCell.h"

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
            _userV = [UIImageView new];
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
    _gkL.text = [NSString stringWithFormat:@"个性后缀：%@", _curUser.global_key];
}

+ (CGFloat)cellHeight{
    return 85;
}
@end
