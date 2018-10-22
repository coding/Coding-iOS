//
//  TeamMemberCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kTeamMemberCell_IconWidth 34.0

#import "TeamMemberCell.h"

@interface TeamMemberCell ()
@property (strong, nonatomic) UIImageView *iconV, *roleV;
@property (strong, nonatomic) UILabel *nameL, *timeL;
@property (nonatomic, strong) UIButton *sliderBtn;
@end

@implementation TeamMemberCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kColorTableBG;
        _iconV = [YLImageView new];
        [_iconV doBorderWidth:.5 color:nil cornerRadius:kTeamMemberCell_IconWidth/2];
        _roleV = [UIImageView new];
        _nameL = [UILabel labelWithSystemFontSize:17 textColorHexString:@"0x222222"];
        _timeL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x999999"];
        [self.contentView addSubview:_iconV];
        [self.contentView addSubview:_roleV];
        [self.contentView addSubview:_nameL];
        [self.contentView addSubview:_timeL];
        
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(kTeamMemberCell_IconWidth, kTeamMemberCell_IconWidth));
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.centerY.equalTo(_roleV);
            make.left.equalTo(_iconV.mas_right).offset(10);
            make.right.equalTo(_roleV.mas_left).offset(-10);
        }];
        [_roleV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameL);
            make.bottom.equalTo(self.contentView).offset(-15);
        }];
        if (!_sliderBtn) {
            _sliderBtn = [UIButton new];
            //for test
            [_sliderBtn setImage:[UIImage imageNamed:@"btn_setFrequent"] forState:UIControlStateNormal];
            [self.contentView addSubview:_sliderBtn];
            [_sliderBtn addTarget:self action:@selector(showSliderAction) forControlEvents:UIControlEventTouchUpInside];
            [_sliderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(40, 40));
                make.right.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView).offset(5);
            }];
        }
    }
    return self;
}

- (void)setCurMember:(TeamMember *)curMember{
    _curMember = curMember;
    if (!_curMember) {
        return;
    }
    [_iconV sd_setImageWithURL:[_curMember.user.avatar urlImageWithCodePathResize:kTeamMemberCell_IconWidth * 2]];
    _nameL.text = _curMember.user.name;
    UIImage *roleImage = [UIImage imageNamed:[NSString stringWithFormat:@"member_type_%@", _curMember.role.stringValue]];
    _roleV.image = roleImage;
    _roleV.hidden = !roleImage;
    
    _timeL.text = [NSString stringWithFormat:@"加入时间：%@", [_curMember.created_at stringWithFormat:@"yyyy-MM-dd HH:mm"]];
}

-(void)showSliderAction{
    [self showRightUtilityButtonsAnimated:YES];
}

+ (CGFloat)cellHeight{
    return 75;
}

@end
