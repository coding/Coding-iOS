//
//  ProjectTopicCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectTopicCell_PadingLeft 55.0
#define kProjectTopicCell_ContentWidth (kScreen_Width - kProjectTopicCell_PadingLeft - kPaddingLeftWidth)
#define kProjectTopicCell_ContentHeightMax 40.0
#define kProjectTopicCell_ContentFont [UIFont systemFontOfSize:16]

#import "ProjectTopicCell.h"

@interface ProjectTopicCell ()
@property (strong, nonatomic) UILabel *titleLabel, *timeLabel, *commentCountLabel;
@property (strong, nonatomic) UIImageView *userIconView, *commentIconView;

@end

@implementation ProjectTopicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width - kPaddingLeftWidth- 15 -20), 0, 12, 12)];
            [_commentIconView setImage:[UIImage imageNamed:@"topic_comment_icon"]];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 10, kProjectTopicCell_ContentWidth, 20)];
            _titleLabel.font = kProjectTopicCell_ContentFont;
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, (kScreen_Width - 120), 15)];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width - kPaddingLeftWidth- 15), 0, 20, 15)];
            _commentCountLabel.font = [UIFont systemFontOfSize:12];
            _commentCountLabel.minimumScaleFactor = 0.5;
            _commentCountLabel.adjustsFontSizeToFitWidth = YES;
            _commentCountLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_commentCountLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_titleLabel setLongString:_curTopic.title withFitWidth:kProjectTopicCell_ContentWidth maxHeight:kProjectTopicCell_ContentHeightMax];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curTopic.owner.name, [_curTopic.created_at stringTimesAgo]];
    
    CGFloat curBottomY = 10 + [_curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, kProjectTopicCell_ContentHeightMax)] + 10;
    [_timeLabel setY:curBottomY];
    
    _commentCountLabel.text = [NSString stringWithFormat:@"%d", _curTopic.child_count.intValue];

    [_commentIconView setY:curBottomY];
    [_commentCountLabel setY:curBottomY];
}

+(CGFloat)cellHeightWithObj:(id)aObj{
    CGFloat cellHeight = 0;
    if ([aObj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *curTopic = (ProjectTopic *)aObj;
        cellHeight += 10 + [curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, kProjectTopicCell_ContentHeightMax)] + 10;
        cellHeight += 15+5;
    }
    return cellHeight;
}

@end
