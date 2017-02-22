//
//  ProjectCodeListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kCode_IconViewWidth 20.0
#define kCode_ContentLeftPading (kPaddingLeftWidth+kCode_IconViewWidth+10)

#import "ProjectCodeListCell.h"

@interface ProjectCodeListCell ()
@property (strong, nonatomic) UIImageView *leftIconView, *commitTimeIcon;
@property (strong, nonatomic) UILabel *fileNameL, *commitorNameL, *commitTimeL;
@end


@implementation ProjectCodeListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        if (!_leftIconView) {
            _leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([self.class cellHeight] - kCode_IconViewWidth)/2, kCode_IconViewWidth, kCode_IconViewWidth)];
            [self.contentView addSubview:_leftIconView];
        }
        if (!_fileNameL) {
            _fileNameL = [[UILabel alloc] initWithFrame:CGRectMake(kCode_ContentLeftPading, 10, kScreen_Width-kCode_ContentLeftPading-30, 20)];
            _fileNameL.font = [UIFont systemFontOfSize:14];
            _fileNameL.textColor = kColor222;
            [self.contentView addSubview:_fileNameL];
        }
        
        if (!_commitorNameL) {
            _commitorNameL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x222222"];
            [self.contentView addSubview:_commitorNameL];
        }
        
        if (!_commitTimeIcon) {
            _commitTimeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"time_clock_icon"]];
            [self.contentView addSubview:_commitTimeIcon];
        }
        
        if (!_commitTimeL) {
            _commitTimeL = [UILabel labelWithSystemFontSize:12 textColorHexString:@"0x999999"];
            [self.contentView addSubview:_commitTimeL];
        }
        [_commitorNameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_fileNameL);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
        [@[_commitTimeIcon, _commitTimeL] mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_commitorNameL);
        }];
        [_commitTimeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_commitorNameL.mas_right).offset(15);
            make.right.equalTo(_commitTimeL.mas_left).offset(-5);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_file) {
        return;
    }
    self.leftIconView.image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_code_%@", _file.mode]];
    if (!self.leftIconView.image) {
        self.leftIconView.image = [UIImage imageNamed:@"icon_code_file"];
    }
    self.fileNameL.text = _file.name;
    
    self.commitorNameL.text = _file.info.lastCommitter.name ?: @"...";
    self.commitTimeL.text = _file.info.lastCommitDate? [_file.info.lastCommitDate stringTimesAgo]: @"...";
}

+ (CGFloat)cellHeight{
    return 60.0;
}

@end

