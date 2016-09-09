//
//  TeamMemberCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamMemberCell.h"

@interface TeamMemberCell ()
@property (strong, nonatomic) UIImageView *iconV, *roleV;
@property (strong, nonatomic) UILabel *nameL;
@end

@implementation TeamMemberCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorTableBG;
        _iconV = [UIImageView new];
        [_iconV doBorderWidth:.5 color:nil cornerRadius:20];
        _roleV = [UIImageView new];
        _nameL = [UILabel labelWithSystemFontSize:17 textColorHexString:@"0x222222"];
        [self.contentView addSubview:_iconV];
        [self.contentView addSubview:_roleV];
        [self.contentView addSubview:_nameL];
        
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@[self.contentView, _nameL, _roleV]);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconV.mas_right).offset(10);
            make.right.equalTo(_roleV.mas_left).offset(-10);
        }];
        [_roleV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)setCurMember:(TeamMember *)curMember{
    _curMember = curMember;
    if (!_curMember) {
        return;
    }
    [_iconV sd_setImageWithURL:[_curMember.user.avatar urlImageWithCodePathResize:40 * 2]];
    _nameL.text = _curMember.user.name;
    UIImage *roleImage = [UIImage imageNamed:[NSString stringWithFormat:@"member_type_%@", _curMember.role.stringValue]];
    _roleV.image = roleImage;
    _roleV.hidden = !roleImage;
}

+ (CGFloat)cellHeight{
    return 60;
}

@end
