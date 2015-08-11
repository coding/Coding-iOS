//
//  TweetCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweet_CommentFont [UIFont systemFontOfSize:14]


#define kTweetCommentCell_LeftOrRightPading 10.0
#define kTweetCommentCell_ContentWidth (kScreen_Width -kPaddingLeftWidth - kPaddingLeftWidth - 2*kTweetCommentCell_LeftOrRightPading)
#define kTweetCommentCell_ContentMaxHeight 105.0

#import "TweetCommentCell.h"

@interface TweetCommentCell ()
@property (strong, nonatomic) UILabel *userNameLabel, *timeLabel;
@property (strong, nonatomic) UIImageView *timeClockIconView, *splitLineView;
@property (strong, nonatomic) Comment *curComment;

@end

@implementation TweetCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        if (!_commentLabel) {
            _commentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTweetCommentCell_LeftOrRightPading, kScaleFrom_iPhone5_Desgin(6), kTweetCommentCell_ContentWidth, 20)];
            _commentLabel.numberOfLines = 0;
            _commentLabel.backgroundColor = [UIColor clearColor];
            _commentLabel.font = kTweet_CommentFont;
            _commentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _commentLabel.linkAttributes = kLinkAttributes;
            _commentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_commentLabel];
        }
        
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCommentCell_LeftOrRightPading, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont boldSystemFontOfSize:10];
            _userNameLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, 80, 15)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:10];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_timeClockIconView) {
            _timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 12, 12)];
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
        if (!_splitLineView) {
            _splitLineView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCommentCell_LeftOrRightPading, 0, 255, 1)];
            _splitLineView.image = [UIImage imageNamed:@"splitlineImg"];
            [self.contentView addSubview:_splitLineView];
            [_splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(kTweetCommentCell_LeftOrRightPading);
                make.top.right.equalTo(self.contentView);
                make.height.mas_equalTo(1.0);
            }];
        }
    }
    return self;
}


- (void)configWithComment:(Comment *)curComment topLine:(BOOL)has{
    _curComment = curComment;
    _splitLineView.hidden = !has;
    User *curUser = _curComment.owner;
//    [_commentLabel setWidth:kTweetCommentCell_ContentWidth];
//    _commentLabel.text = _curComment.content;
//    [_commentLabel sizeToFit];
    [_commentLabel setLongString:_curComment.content withFitWidth:kTweetCommentCell_ContentWidth maxHeight:kTweetCommentCell_ContentMaxHeight];

    for (HtmlMediaItem *item in _curComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_commentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    CGFloat curBottomY = CGRectGetMaxY(_commentLabel.frame) +kScaleFrom_iPhone5_Desgin(5);
    
    _userNameLabel.text = curUser.name;
    _timeLabel.text = [_curComment.created_at stringDisplay_HHmm];
    [_userNameLabel setY:curBottomY];
    [_userNameLabel sizeToFit];
    
    CGRect frame = _timeClockIconView.frame;
    frame.origin.y = curBottomY;
    frame.origin.x = 15+ CGRectGetWidth(_userNameLabel.frame);
    _timeClockIconView.frame = frame;
    
    frame.origin.x += 15;
    frame.size = _timeLabel.frame.size;
    _timeLabel.frame = frame;
    [_timeLabel sizeToFit];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Comment class]]) {
        Comment *curComment = (Comment *)obj;
        cellHeight = MIN(kTweetCommentCell_ContentMaxHeight, [curComment.content getHeightWithFont:kTweet_CommentFont constrainedToSize:CGSizeMake(kTweetCommentCell_ContentWidth, CGFLOAT_MAX)]) +15 + kScaleFrom_iPhone5_Desgin(15);
    }
    return ceilf(cellHeight);
}
@end
