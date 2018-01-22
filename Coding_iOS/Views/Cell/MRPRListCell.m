//
//  MRPRListCell.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRListCell.h"

@interface MRPRListCell ()
@property (strong, nonatomic) UIImageView *statusIcon;
@property (strong, nonatomic) UILabel *titleL, *numL, *authorL, *timeL, *commentCountL;
@property (strong, nonatomic) UIImageView *timeIcon, *commentIcon, *arrowIcon;
@property (strong, nonatomic) UILabel *fromL, *toL;
@end

@implementation MRPRListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = kColorTableBG;
        _statusIcon = [UIImageView new];
        _titleL = [UILabel labelWithSystemFontSize:15 textColorHexString:@"0x323A45"];
        _numL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _authorL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _timeL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _commentCountL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _timeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_clock_icon"]];
        _commentIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topic_comment_icon"]];
        _arrowIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mrpr_icon_arrow"]];
        _fromL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _fromL.backgroundColor = [UIColor colorWithHexString:@"0xF2F4F6"];
        _fromL.cornerRadius = 2;
        _fromL.masksToBounds = YES;
        _toL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x76808E"];
        _toL.backgroundColor = [UIColor colorWithHexString:@"0xD8DDE4"];
        _toL.cornerRadius = 2;
        _toL.masksToBounds = YES;

        for (UIView *tempV in @[_statusIcon, _titleL, _numL, _authorL, _timeL, _commentCountL, _timeIcon, _commentIcon, _arrowIcon, _fromL, _toL]) {
            [self.contentView addSubview:tempV];
        }
        [_statusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(15);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_statusIcon);
            make.left.equalTo(_statusIcon.mas_right).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(21);
        }];
        [_fromL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(5);
            make.height.mas_equalTo(22);
            make.left.equalTo(_titleL);
        }];
        [_arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fromL.mas_right).offset(10);
            make.right.equalTo(_toL.mas_left).offset(-10);
            make.centerY.equalTo(_fromL);
        }];
        [_toL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_fromL);
            make.height.mas_equalTo(22);
        }];
        [_numL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_fromL.mas_bottom).offset(10);
            make.left.equalTo(_titleL);
            make.height.mas_equalTo(17);
        }];
        [@[_authorL, _timeIcon, _timeL, _commentIcon, _commentCountL] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_numL);
        }];
        [_authorL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_numL.mas_right).offset(10);
            make.right.equalTo(_timeIcon.mas_left).offset(-10);
        }];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_timeIcon.mas_right).offset(5);
            make.right.equalTo(_commentIcon.mas_left).offset(-10);
        }];
        [_commentCountL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_commentIcon.mas_right).offset(5);
        }];
    }
    return self;
}

- (void)setCurMRPR:(MRPR *)curMRPR{
    _curMRPR = curMRPR;
    if (!_curMRPR) {
        return;
    }
    _statusIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"mrpr_icon_status_%@", [_curMRPR.merge_status lowercaseString]]];
    _titleL.text = _curMRPR.title;
    _numL.text = [NSString stringWithFormat:@"#%@", _curMRPR.iid.stringValue ?: @""];
    _authorL.text = _curMRPR.author.name;
    _timeL.text = [_curMRPR.created_at stringDisplay_HHmm];
    _commentCountL.text = _curMRPR.comment_count.stringValue;
    _commentCountL.hidden = _commentIcon.hidden = (_curMRPR.comment_count == nil);
    
    NSString *fromStr, *toStr;
    if (_curMRPR.isMR) {
        fromStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@  ", _curMRPR.desBranch];
    }else{
        fromStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.src_owner_name ?: @"已删除项目", _curMRPR.srcBranch];
        toStr = [NSString stringWithFormat:@"  %@ : %@  ", _curMRPR.des_owner_name ?: @"已删除项目", _curMRPR.desBranch];
    }
    _fromL.text = fromStr;
    _toL.text = toStr;
}


+ (CGFloat)cellHeight{
    return 110.0;
}
@end
