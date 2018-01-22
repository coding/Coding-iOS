//
//  WikiHeaderView.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/7.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "WikiHeaderView.h"

@interface WikiHeaderView ()
@property (strong, nonatomic) UILabel *titleL, *nameL, *timeL, *versionL;
@end

@implementation WikiHeaderView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreen_Width, 0);
        _titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:17 weight:UIFontWeightMedium] textColor:kColorDark2];
        _nameL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColorDark7];
        _timeL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColorDark7];
        _versionL = [UILabel labelWithFont:[UIFont systemFontOfSize:12] textColor:kColorDark7];
        [self addSubview:_titleL];
        [self addSubview:_nameL];
        [self addSubview:_timeL];
        [self addSubview:_versionL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(kPaddingLeftWidth);
            make.right.equalTo(self).offset(-kPaddingLeftWidth);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleL);
            make.top.equalTo(_titleL.mas_bottom).offset(10);
            make.height.mas_equalTo(17);
        }];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_nameL.mas_right).offset(10);
            make.right.equalTo(_versionL.mas_left).offset(-10);
            make.centerY.equalTo(_nameL);
        }];
        [_versionL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_nameL);
        }];
        UIView *lineV = [UIView lineViewWithPointYY:0];
        [self addSubview:lineV];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
            make.right.left.equalTo(_titleL);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setCurWiki:(EAWiki *)curWiki{
    _curWiki = curWiki;
    
    self.hidden = (_curWiki == nil);
    if (!_curWiki) {
        self.height = 0;
    }else{
        _titleL.text = _curWiki.mdTitle;
        _nameL.text = _curWiki.editor.name;
        _timeL.text = [NSString stringWithFormat:@"更新于 %@", [_curWiki.updatedAt stringWithFormat:@"MM/dd HH:mm"]];
        _versionL.text = [NSString stringWithFormat:@"当前版本 %@", _curWiki.currentVersion];
        
        _nameL.hidden = _timeL.hidden = _versionL.hidden = _isForEdit;
        
        CGFloat height = [_titleL.text getHeightWithFont:_titleL.font constrainedToSize:CGSizeMake(_titleL.width, kCGGlyphMax)];
        if (_isForEdit) {
            height = 15 + height + 15 + 1;
        }else{
            height = 15 + height + 10 + 17 + 15 + 1;
        }
        self.frame = CGRectMake(0, -height, kScreen_Width, height);
    }
}

@end
