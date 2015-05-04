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
@property (strong, nonatomic) UILabel *titleLabel, *userNameLabel, *timeLabel, *commentCountLabel;
@property (strong, nonatomic) UIImageView *userIconView, *timeClockIconView, *commentIconView;

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
        if (!_timeClockIconView) {
            _timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 12, 12)];
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 12, 12)];
            [_commentIconView setImage:[UIImage imageNamed:@"topic_comment_icon"]];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 10, kProjectTopicCell_ContentWidth, 20)];
            _titleLabel.font = kProjectTopicCell_ContentFont;
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont systemFontOfSize:10];
            _userNameLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 80, 15)];
            _timeLabel.font = [UIFont systemFontOfSize:10];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTopicCell_PadingLeft, 0, 20, 15)];
            _commentCountLabel.font = [UIFont systemFontOfSize:10];
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
    if (!_curTopic) {
        return;
    }
    [_userIconView sd_setImageWithURL:[_curTopic.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_titleLabel setLongString:_curTopic.title withFitWidth:kProjectTopicCell_ContentWidth maxHeight:kProjectTopicCell_ContentHeightMax];
    
    CGFloat curBottomY = 10 + [_curTopic.title getHeightWithFont:kProjectTopicCell_ContentFont constrainedToSize:CGSizeMake(kProjectTopicCell_ContentWidth, kProjectTopicCell_ContentHeightMax)] + 10;
    CGFloat curRightX = kProjectTopicCell_PadingLeft;

    [_userNameLabel setOrigin:CGPointMake(curRightX, curBottomY)];
    _userNameLabel.text = _curTopic.owner.name;
    [_userNameLabel sizeToFit];
    
    curRightX = _userNameLabel.maxXOfFrame+ 10;
    [_timeClockIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_timeLabel setOrigin:CGPointMake(curRightX + 15, curBottomY)];
    _timeLabel.text = [_curTopic.created_at stringTimesAgo];
    [_timeLabel sizeToFit];
    
    curRightX = _timeLabel.maxXOfFrame + 10;
    [_commentIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_commentCountLabel setOrigin:CGPointMake(curRightX +15, curBottomY)];
    _commentCountLabel.text = _curTopic.child_count.stringValue;
    [_commentCountLabel sizeToFit];
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
