//
//  CommitContentCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCommitContentCell_FontTitle [UIFont boldSystemFontOfSize:18]

#import "CommitContentCell.h"

@interface CommitContentCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *titleL, *timeL, *statusL;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation CommitContentCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 20, 20)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        CGFloat curWidth = kScreen_Width - 2 * kPaddingLeftWidth;
        if (!_titleL) {
            _titleL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15,  curWidth, 30)];
            _titleL.textColor = kColor222;
            _titleL.font = kCommitContentCell_FontTitle;
            [self.contentView addSubview:_titleL];
        }
        if (!_timeL) {
            _timeL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _timeL.textColor = kColor999;
            _timeL.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeL];
            [_timeL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_userIconView.mas_right).offset(5);
                make.centerY.equalTo(_userIconView);
                make.height.mas_equalTo(20);
            }];
        }
        if (!_statusL) {
            _statusL = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +25, 0, curWidth, 20)];
            _statusL.textColor = [UIColor colorWithHexString:@"0xFB3B30"];
            _statusL.font = [UIFont systemFontOfSize:12];
            _statusL.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_statusL];
            [_statusL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_timeL.mas_right).offset(10);
                make.centerY.height.equalTo(_timeL);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.width.mas_equalTo(80);
            }];
        }
        if (!_lineView) {
            _lineView = [UIView new];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
            [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.bottom.equalTo(self.contentView).offset(-0.5);
                make.height.mas_equalTo(0.5);
            }];
        }
    }
    return self;
}

- (void)setCurCommitInfo:(CommitInfo *)curCommitInfo{
    _curCommitInfo = curCommitInfo;
    if (!_curCommitInfo) {
        return;
    }
    CGFloat curBottomY = 0;
    CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
    [_titleL setLongString:_curCommitInfo.commitDetail.fullMessage withFitWidth:curWidth];
    
    curBottomY += CGRectGetMaxY(_titleL.frame) + 15;
    [_userIconView sd_setImageWithURL:[_curCommitInfo.commitDetail.committer.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_userIconView setY:curBottomY];
    
    _timeL.attributedText = [self attributeTimeStr];
    _statusL.text =  _curCommitInfo.commitDetail.commitId.length > 10? [_curCommitInfo.commitDetail.commitId substringToIndex:10]: _curCommitInfo.commitDetail.commitId;
}

- (NSAttributedString *)attributeTimeStr{
    NSString *nameStr = _curCommitInfo.commitDetail.committer.name? _curCommitInfo.commitDetail.committer.name: @"";
    NSString *timeStr = _curCommitInfo.commitDetail.commitTime? [_curCommitInfo.commitDetail.commitTime stringDisplay_HHmm]: @"";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : kColor222}
                         range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                 NSForegroundColorAttributeName : kColor999}
                         range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attrString;
}


+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[CommitInfo class]]) {
        CommitInfo *curCommitInfo = (CommitInfo *)obj;
        CGFloat curWidth = kScreen_Width -2*kPaddingLeftWidth;
        cellHeight += 8 + [curCommitInfo.commitDetail.fullMessage getHeightWithFont:kCommitContentCell_FontTitle constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)];
        cellHeight += 15 + 15 + 20 + 15;
    }
    return cellHeight;
}
@end
