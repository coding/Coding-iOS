//
//  TweetDetailCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetDetailCommentCell_FontContent [UIFont systemFontOfSize:15]

#import "TweetDetailCommentCell.h"
#import "Login.h"

@interface TweetDetailCommentCell ()
//@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UILabel *userNameLabel, *timeLabel;
@property (strong, nonatomic) UIImageView *timeClockIconView;

@end

@implementation TweetDetailCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15, kScreen_Width - 2*kPaddingLeftWidth, 30)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.textColor = kColorDark4;
            _contentLabel.font = kTweetDetailCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont systemFontOfSize:12];
            _userNameLabel.textColor = kColorDark7;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 80, 15)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = kColorDark7;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_timeClockIconView) {
            _timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 15, 15)];
            _timeClockIconView.contentMode = UIViewContentModeCenter;
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_toComment) {
        return;
    }
    CGFloat curBottomY = 15;
    CGFloat curWidth = kScreen_Width - 2*kPaddingLeftWidth;
    [_contentLabel setWidth:curWidth];
    _contentLabel.text = _toComment.content;
    [_contentLabel sizeToFit];

    for (HtmlMediaItem *item in _toComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_toComment.content getHeightWithFont:kTweetDetailCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 10;
    
    
    _userNameLabel.text = _toComment.owner.name;
    _timeLabel.text = [_toComment.created_at stringDisplay_HHmm];
    [_userNameLabel setY:curBottomY];
    [_userNameLabel sizeToFit];
    
    CGRect frame = _timeClockIconView.frame;
    frame.origin.y = curBottomY;
    frame.origin.x = 10 + CGRectGetMaxX(_userNameLabel.frame);
    _timeClockIconView.frame = frame;
    
    frame.origin.x += 5 + CGRectGetWidth(_timeClockIconView.frame);
    frame.size = _timeLabel.frame.size;
    _timeLabel.frame = frame;
    [_timeLabel sizeToFit];
}

- (void)commentBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_commentToCommentBlock) {
        _commentToCommentBlock(_toComment, weakSelf);
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Comment class]]) {
        Comment *toComment = (Comment *)obj;
        CGFloat curWidth = kScreen_Width - 2*kPaddingLeftWidth;
        cellHeight += 15 +[toComment.content getHeightWithFont:kTweetDetailCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 10 +15 +15;
    }
    return cellHeight;
}


@end
