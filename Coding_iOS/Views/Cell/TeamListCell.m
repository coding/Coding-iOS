//
//  TeamListCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TeamListCell.h"

@interface TeamListCell ()
@property (strong, nonatomic) UIImageView *iconV;
@property (strong, nonatomic) UILabel *nameL;
@property (strong, nonatomic) UILabel *proL, *proTL, *memL, *memTL;
@end

@implementation TeamListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorTableBG;
        _iconV = [UIImageView new];
        [_iconV doBorderWidth:.5 color:nil cornerRadius:2.0];
        _nameL = [UILabel labelWithSystemFontSize:15 textColorHexString:@"0x323A45"];
        _proL = [UILabel labelWithSystemFontSize:14 textColorHexString:@"0x4F565F"];
        _memL = [UILabel labelWithSystemFontSize:14 textColorHexString:@"0x4F565F"];
        
        _proTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _memTL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _proTL.text = @"项目";
        _memTL.text = @"成员";
        for (UIView *subV in @[_iconV, _nameL, _proL, _proTL, _memL, _memTL]) {
            [self.contentView addSubview:subV];
        }
        
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(70, 70));
            make.centerY.equalTo(self.contentView);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconV.mas_right).offset(15);
            make.top.equalTo(_iconV).offset(5);
        }];
        [_proTL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameL);
            make.top.equalTo(_iconV.mas_centerY).offset(5);
            make.baseline.equalTo(@[_proL, _memTL, _memL]);
        }];
        [_proL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_proTL.mas_right).offset(5);
        }];
        [_memTL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconV.mas_right).offset(85);
        }];
        [_memL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_memTL.mas_right).offset(5);
        }];
    }
    return self;
}

- (void)setCurTeam:(Team *)curTeam{
    _curTeam = curTeam;
    
    [_iconV sd_setImageWithURL:[_curTeam.avatar urlImageWithCodePathResize:70 * 2]];
    _nameL.text = _curTeam.name;
    _proL.text = _curTeam.project_count.stringValue;
    _memL.text = _curTeam.member_count.stringValue;
}

+ (CGFloat)cellHeight{
    return 95;
}
@end
