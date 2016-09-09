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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _iconV = [UIImageView new];
        [_iconV doBorderWidth:0 color:nil cornerRadius:2.0];
        _nameL = [UILabel labelWithSystemFontSize:15 textColorHexString:@"0x1E2D42"];
        _introductionL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x999999"];
        _introductionL.numberOfLines = 0;
        for (UIView *subV in @[_iconV, _nameL, _introductionL]) {
            [self.contentView addSubview:subV];
        }
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(80, 80));
            make.centerY.equalTo(self.contentView);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconV.mas_right).offset(15);
            make.top.equalTo(_iconV).offset(5);
        }];
        [_introductionL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameL);
            make.top.equalTo(_nameL.mas_bottom).offset(10);
            make.bottom.equalTo(_iconV.mas_bottom).offset(-5);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)setCurTeam:(Team *)curTeam{
    _curTeam = curTeam;
    
    [_iconV sd_setImageWithURL:[_curTeam.avatar urlImageWithCodePathResize:70 * 2]];
    _nameL.text = _curTeam.name;
    _introductionL.text = _curTeam.introduction;
}

+ (CGFloat)cellHeight{
    return 100;
}
@end
