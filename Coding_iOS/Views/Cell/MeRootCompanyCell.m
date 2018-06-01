//
//  MeRootCompanyCell.m
//  Coding_Enterprise_iOS
//
//  Created by Ease on 2016/12/30.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MeRootCompanyCell.h"

@interface MeRootCompanyCell ()
@property (strong, nonatomic) UIImageView *iconV;
@property (strong, nonatomic) UILabel *nameL, *descriptionL;
@end

@implementation MeRootCompanyCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_iconV) {
            _iconV = [UIImageView new];
            [self.contentView addSubview:_iconV];
        }
        if (!_nameL) {
            _nameL = [UILabel labelWithSystemFontSize:16 textColorHexString:@"0x1E2D42"];
            [self.contentView addSubview:_nameL];
        }
        if (!_descriptionL) {
            _descriptionL = [UILabel labelWithFont:[UIFont systemFontOfSize:13] textColor:[UIColor colorWithHexString:@"0x1E2D42" andAlpha:0.6]];
            [self.contentView addSubview:_descriptionL];
        }
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(22, 22));
            make.centerY.equalTo(self.contentView);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.left.equalTo(_iconV.mas_right).offset(15);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        [_descriptionL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.left.right.equalTo(_nameL);
        }];
        
    }
    return self;
}

- (void)setCurCompany:(Team *)curCompany{
    _curCompany = curCompany;
    _iconV.image = [UIImage imageNamed:@"user_info_company"];
    _nameL.text = _curCompany.name;
    _descriptionL.text = @"企业账户管理中心";
}

+ (CGFloat)cellHeight{
    return 75;
}
@end
