//
//  CommitListCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCommitListCell_UserWidth 33.0

#import "CommitListCell.h"

@interface CommitListCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel, *subTitleLabel;
@end

@implementation CommitListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            _imgView = [UIImageView new];
            [_imgView doBorderWidth:0.5 color:kColorDDD cornerRadius:kCommitListCell_UserWidth/2];
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kCommitListCell_UserWidth, kCommitListCell_UserWidth));
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
                make.top.equalTo(self.contentView).offset(15);
                make.height.mas_equalTo(30);
            }];
        }
        if (!_subTitleLabel) {
            _subTitleLabel = [UILabel new];
            [self.contentView addSubview:_subTitleLabel];
            [_subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.height.equalTo(_titleLabel);
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            }];
        }
    }
    return self;
}

- (void)setCurCommit:(Commit *)curCommit{
    _curCommit = curCommit;
    if (!_curCommit) {
        return;
    }
    [_imgView sd_setImageWithURL:[curCommit.committer.avatar urlImageWithCodePathResize:2*kCommitListCell_UserWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(2*kCommitListCell_UserWidth)];
    _titleLabel.attributedText = [self titleStr];
    _subTitleLabel.attributedText = [self subTitleStr];
}

- (NSAttributedString *)titleStr{
    NSString *commitIdStr = _curCommit.commitId.length > 10? [_curCommit.commitId substringToIndex:10] : _curCommit.commitId;
    NSString *contentStr = _curCommit.shortMessage? _curCommit.shortMessage: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", commitIdStr, contentStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]}
                         range:NSMakeRange(0, commitIdStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14],
                                 NSForegroundColorAttributeName : kColor222}
                         range:NSMakeRange(commitIdStr.length + 1, contentStr.length)];
    return attrString;
}

- (NSAttributedString *)subTitleStr{
    NSString *nameStr = _curCommit.committer.name? _curCommit.committer.name: @"";
    NSString *timeStr = _curCommit.commitTime? [_curCommit.commitTime stringDisplay_HHmm]: @"";
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
