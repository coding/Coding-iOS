//
//  MRPRListCell.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kMRPRListCell_UserWidth 33.0

#import "MRPRListCell.h"

@interface MRPRListCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel, *subTitleLabel;
@end

@implementation MRPRListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (!_imgView) {
            _imgView = [UIImageView new];
            _imgView.layer.masksToBounds = YES;
            _imgView.layer.cornerRadius = kMRPRListCell_UserWidth/2;
            _imgView.layer.borderWidth = 0.5;
            _imgView.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kMRPRListCell_UserWidth, kMRPRListCell_UserWidth));
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_titleLabel) {
            _titleLabel = [UILabel new];
            [self.contentView addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgView.mas_right).offset(12);
                make.right.equalTo(self.contentView);
//                .offset(-kPaddingLeftWidth);
                make.top.equalTo(self.contentView).offset(15);
                make.height.mas_equalTo(15);
            }];
        }
        if (!_subTitleLabel) {
            _subTitleLabel = [UILabel new];
            [self.contentView addSubview:_subTitleLabel];
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.height.equalTo(_titleLabel);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-15);
            }];
        }
    }
    return self;
}

- (void)configWithMRPR:(MRPR *)curMRPR{
    [_imgView sd_setImageWithURL:[curMRPR.author.avatar urlImageWithCodePathResize:2*kMRPRListCell_UserWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(2*kMRPRListCell_UserWidth)];
    _titleLabel.attributedText = curMRPR.attributeTitle;
    _subTitleLabel.attributedText = curMRPR.attributeTail;
}
+ (CGFloat)cellHeight{
    return 70.0;
}
@end
