//
//  ProjectInfoCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectInfoCell_ProImgViewWidth kScaleFrom_iPhone5_Desgin(55.0)

#import "ProjectInfoCell.h"

@interface ProjectInfoCell ()
@property (strong, nonatomic) UIImageView *proImgView;
@property (strong, nonatomic) UILabel *proTitleL, *ownerGlobalkeyL;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation ProjectInfoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_proImgView) {
            _proImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kProjectInfoCell_ProImgViewWidth, kProjectInfoCell_ProImgViewWidth)];
            _proImgView.layer.cornerRadius = 2.0;
            _proImgView.layer.masksToBounds = YES;
            [self.contentView addSubview:_proImgView];
        }
        if (!_proTitleL) {
            _proTitleL = [[UILabel alloc] init];
            _proTitleL.font = [UIFont systemFontOfSize:17];
            _proTitleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_proTitleL];
        }
        if (!_ownerGlobalkeyL) {
            _ownerGlobalkeyL = [[UILabel alloc] init];
            _ownerGlobalkeyL.font = [UIFont systemFontOfSize:13];
            _ownerGlobalkeyL.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_ownerGlobalkeyL];
        }
        if (!_lineView) {
            _lineView = [[UIView alloc] init];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
        }
    }
    return self;
}

+ (CGFloat)cellHeight{
    
    return kScaleFrom_iPhone5_Desgin(80.0);
}

- (void)setCurProject:(Project *)curProject{
    _curProject = curProject;
    if (!_curProject) {
        return;
    }
    [_proImgView sd_setImageWithURL:[_curProject.icon urlImageWithCodePathResize:2*kProjectInfoCell_ProImgViewWidth] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    _proTitleL.text = _curProject.name;
    _ownerGlobalkeyL.text = _curProject.owner_user_name;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat pading = kPaddingLeftWidth;
    
    [_proImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(pading);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kProjectInfoCell_ProImgViewWidth, kProjectInfoCell_ProImgViewWidth));
    }];
    [_proTitleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_proImgView.mas_right).offset(pading);
        make.right.equalTo(self.contentView.mas_right).offset(-pading);
        make.bottom.equalTo(_proImgView.mas_centerY);
        make.height.mas_equalTo(20);
    }];
    [_ownerGlobalkeyL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(_proTitleL);
        make.top.equalTo(_proTitleL.mas_bottom).offset(5);
        make.height.mas_equalTo(15);
    }];
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_proImgView.mas_left);
        make.right.equalTo(_proTitleL.mas_right);
        make.bottom.equalTo(self.contentView);
        make.height.mas_equalTo(1.0);
    }];
}
@end
