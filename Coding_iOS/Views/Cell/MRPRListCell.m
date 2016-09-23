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
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            _imgView = [UIImageView new];
            _imgView.layer.masksToBounds = YES;
            _imgView.layer.cornerRadius = kMRPRListCell_UserWidth/2;
            _imgView.layer.borderWidth = 0.5;
            _imgView.layer.borderColor = kColorDDD.CGColor;
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
                make.top.equalTo(self.contentView).offset(13);
                make.height.mas_equalTo(20);
            }];
        }
        if (!_subTitleLabel) {
            _subTitleLabel = [UILabel new];
            [self.contentView addSubview:_subTitleLabel];
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.height.equalTo(_titleLabel);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-13);
            }];
        }
    }
    return self;
}

- (void)setCurMRPR:(MRPR *)curMRPR{
    _curMRPR = curMRPR;
    if (!_curMRPR) {
        return;
    }
    [_imgView sd_setImageWithURL:[_curMRPR.author.avatar urlImageWithCodePathResize:2*kMRPRListCell_UserWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(2*kMRPRListCell_UserWidth)];
    _titleLabel.attributedText = [self attributeTitle];
    _subTitleLabel.attributedText = [self attributeTail];
}

- (NSAttributedString *)attributeTitle{
    NSString *iidStr = [NSString stringWithFormat:@"#%@", _curMRPR.iid.stringValue? _curMRPR.iid.stringValue: @""];
    NSString *titleStr = _curMRPR.title? _curMRPR.title: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", iidStr, titleStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]}
                        range:NSMakeRange(0, iidStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                NSForegroundColorAttributeName : kColor222}
                        range:NSMakeRange(iidStr.length + 1, titleStr.length)];
    return attrString;
}

- (NSAttributedString *)attributeTail{
    NSString *nameStr = _curMRPR.author.name? _curMRPR.author.name: @"";
    NSString *timeStr = _curMRPR.created_at? [_curMRPR.created_at stringDisplay_HHmm]: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor222}
                        range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor999}
                        range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attrString;
}


+ (CGFloat)cellHeight{
    return 70.0;
}
@end
