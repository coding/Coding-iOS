//
//  WikiHistoryCell.m
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/10.
//  Copyright © 2017年 Coding. All rights reserved.
//

#define kWikiHistoryCell_MsgWidth (kScreen_Width - 120)

#import "WikiHistoryCell.h"

@interface WikiHistoryCell ()
@property (strong, nonatomic) UILabel *versionL, *timeL, *editorL, *msgL;
@end

@implementation WikiHistoryCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _versionL = [UILabel labelWithFont:[UIFont systemFontOfSize:15] textColor:kColorDark3];
        _timeL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _editorL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        _msgL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark3];
        UILabel *editorTitleL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        UILabel *msgTitleL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorDark7];
        UIView *lineV = [UIView new];
        lineV.backgroundColor = kColorDDD;
        _timeL.textAlignment = _editorL.textAlignment = _msgL.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:_versionL];
        [self.contentView addSubview:_timeL];
        [self.contentView addSubview:lineV];
        [self.contentView addSubview:editorTitleL];
        [self.contentView addSubview:_editorL];
        [self.contentView addSubview:msgTitleL];
        [self.contentView addSubview:_msgL];
        
        [_versionL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.height.mas_equalTo(24);
        }];
        [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.centerY.equalTo(_versionL);
        }];
        [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.0/[UIScreen mainScreen].scale);
            make.top.equalTo(self.contentView).offset(44);
            make.left.equalTo(_versionL);
            make.right.equalTo(self.contentView);
        }];
        [editorTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_versionL);
            make.height.mas_equalTo(20);
            make.top.equalTo(lineV.mas_bottom).offset(10);
        }];
        [_editorL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_timeL);
            make.centerY.equalTo(editorTitleL);
        }];
        [msgTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(_versionL);
            make.top.equalTo(editorTitleL.mas_bottom).offset(10);
        }];
        [_msgL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_timeL);
            make.top.equalTo(msgTitleL);
            make.width.mas_equalTo(kWikiHistoryCell_MsgWidth);
        }];
        editorTitleL.text = @"创建者";
        msgTitleL.text = @"提交信息";
    }
    return self;
}

- (void)setCurWiki:(EAWiki *)curWiki{
    _curWiki = curWiki;
    
    _versionL.text = [NSString stringWithFormat:@"版本 %@", _curWiki.version];
    _timeL.text = [_curWiki.createdAt stringWithFormat:@"MM-dd HH:mm"];
    _editorL.text = _curWiki.editor.name;
    _msgL.text = _curWiki.msg.length > 0? _curWiki.msg : @"--";
}

+ (CGFloat)cellHeightWithObj:(EAWiki *)obj{
    CGFloat cellHeight = 115;
    CGFloat msgHeight = [obj.msg getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kWikiHistoryCell_MsgWidth, CGFLOAT_MAX)];
    if (msgHeight > 20) {
        cellHeight += (msgHeight - 20);
    }
    return cellHeight;
}
@end
