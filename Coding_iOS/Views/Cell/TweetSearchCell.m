//
//  TweetSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "TweetSearchCell.h"
#import "UICustomCollectionView.h"
#import "TweetMediaItemCCell.h"
#import "TweetMediaItemSingleCCell.h"
#import "TweetLikeUserCCell.h"
#import "MJPhotoBrowser.h"

#define kTweetCell_PadingLeft (15+40+kInnerHorzionOffset)
#define kTweetCell_PadingTop 15.0
#define kTweetCell_PadingBottom 10.0
#define kTweetCell_ContentWidth (kScreen_Width - kTweetCell_PadingLeft - 30)
#define kTweet_ContentMaxHeight 36.0
#define kTweet_ContentFont [UIFont systemFontOfSize:15]
#define kTweetCell_LikeUserCCell_Height 25.0
#define kInnerHorzionOffset 12
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweetCell_NameMaxWidth (kTweetCell_ContentWidth - )

@interface TweetSearchCell ()

@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UILabel *timeLabel, *nameLabel, *likeLabel, *commentLabel;
@property (strong, nonatomic) UIImageView *timeClockIconView, *tweetCommentIconView, *tweetLikeIconView, *detailIconView;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;

@end

@implementation TweetSearchCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(15, 18, 40, 40)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
        }
        
        if (!self.contentLabel) {
            self.contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 15, kTweetCell_ContentWidth, 20)];
            self.contentLabel.font = kTweet_ContentFont;
            self.contentLabel.textColor = kColor222;
            self.contentLabel.numberOfLines = 0;
            
            self.contentLabel.linkAttributes = kLinkAttributes;
            self.contentLabel.activeLinkAttributes = kLinkAttributesActive;
            self.contentLabel.delegate = self;
            [self.contentLabel addLongPressForCopy];
            [self.contentView addSubview:self.contentLabel];
        }
        
        if(!self.nameLabel) {
            self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 0, 12)];
            self.nameLabel.font = kTweet_TimtFont;
            self.nameLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.nameLabel];
        }
        
        if (!self.timeClockIconView) {
            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 12, 12)];
            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:self.timeClockIconView];
        }
        
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 55, 12)];
            self.timeLabel.font = kTweet_TimtFont;
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.timeLabel.textColor = kColor999;
            [self.contentView addSubview:self.timeLabel];
        }
        
        if(!self.tweetLikeIconView) {
            self.tweetLikeIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 12, 12)];
            //TODO psy 需要like icon
            self.tweetLikeIconView.image = [UIImage imageNamed:@"search_tweet_like"];
            [self.contentView addSubview:self.tweetLikeIconView];
        }
        
        if (!self.likeLabel) {
            self.likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 55, 12)];
            self.likeLabel.font = kTweet_TimtFont;
            self.likeLabel.textAlignment = NSTextAlignmentLeft;
            self.likeLabel.textColor = kColor999;
            [self.contentView addSubview:self.likeLabel];
        }
        
        if(!self.tweetCommentIconView) {
            self.tweetCommentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 12, 12)];
            self.tweetCommentIconView.image = [UIImage imageNamed:@"topic_comment_icon"];
            [self.contentView addSubview:self.tweetCommentIconView];
        }
        
        if (!self.commentLabel) {
            self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 55, 12)];
            self.commentLabel.font = kTweet_TimtFont;
            self.commentLabel.textAlignment = NSTextAlignmentLeft;
            self.commentLabel.textColor = kColor999;
            [self.contentView addSubview:self.commentLabel];
        }
        
        if(!self.detailIconView) {
            //            self.detailIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 8, 0, 20, 20)];
            //            self.detailIconView.image = [UIImage imageNamed:@"me_info_arrow_left"];
            //            [self.contentView addSubview:self.detailIconView];
        }
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    __weak __typeof(self) weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    
    NSString *contentStr = (_tweet.content.length > 0) ? _tweet.content : @"[图片]";
    self.contentLabel.text = contentStr;
    self.contentLabel.height = [TweetSearchCell contentLabelHeightWithTweet:_tweet];
    
    //    [self.contentLabel setLongString:contentStr withFitWidth:kTweetCell_ContentWidth maxHeight:kTweet_ContentMaxHeight];
    //
    for (HtmlMediaItem *item in _tweet.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    CGFloat curBottomY = self.frame.size.height-12-15;
    
    CGFloat curX = kTweetCell_PadingLeft;
    [self.nameLabel setLongString:_tweet.owner.name withVariableWidth:kScreen_Width / 2];
    [self.nameLabel setY:curBottomY];
    
    curX += self.nameLabel.frame.size.width + 7;
    [self.timeClockIconView setX:curX];
    [self.timeClockIconView setY:curBottomY + 2];
    
    curX += self.timeClockIconView.frame.size.width + 3;
    [self.timeLabel setLongString:[_tweet.created_at stringDisplay_HHmm] withVariableWidth:kScreen_Width / 2];
    [self.timeLabel setX:curX];
    [self.timeLabel setY:curBottomY];
    
    curX += self.timeLabel.frame.size.width + 7;
    [self.tweetLikeIconView setX:curX];
    [self.tweetLikeIconView setY:curBottomY + 2];
    
    curX += self.tweetLikeIconView.frame.size.width + 3;
    [self.likeLabel setLongString:[_tweet.likes stringValue] withVariableWidth:kScreen_Width / 6];
    [self.likeLabel setX:curX];
    [self.likeLabel setY:curBottomY];
    
    curX += self.likeLabel.frame.size.width + 7;
    [self.tweetCommentIconView setX:curX];
    [self.tweetCommentIconView setY:curBottomY + 2];
    
    curX += self.tweetCommentIconView.frame.size.width + 3;
    [self.commentLabel setLongString:[_tweet.comments stringValue] withVariableWidth:kScreen_Width / 6];
    [self.commentLabel setX:curX];
    [self.commentLabel setY:curBottomY];
    
    [self.detailIconView setY:([TweetSearchCell cellHeightWithObj:_tweet] - 12) / 2];
}

+ (CGFloat)cellHeightWithObj:(id)obj {
    /**
     --space = 15
     content
     --space
     icons
     --space
     */
    
    Tweet *tweet = (Tweet *)obj;
    CGFloat cellHeight = 0;

    cellHeight += 18+20+12+5;
    //    cellHeight += kTweetCell_PadingTop;
    cellHeight += [TweetSearchCell contentLabelHeightWithTweet:tweet];
    cellHeight += 15;
    return cellHeight;
}

+ (CGFloat)contentLabelHeightWithTweet:(Tweet *)tweet {
    NSString *content = (tweet.content.length > 0) ? tweet.content : @"[图片]";
    CGFloat realheight = [content getHeightWithFont:kTweet_ContentFont constrainedToSize:CGSizeMake(kTweetCell_ContentWidth, 1000)];
    return MIN(realheight, kTweet_ContentMaxHeight);
}


- (void)userBtnClicked {
    
    if (_userBtnClickedBlock) {
        _userBtnClickedBlock(_tweet.owner);
    }
}

#pragma -
#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    
    if (_mediaItemClickedBlock) {
        _mediaItemClickedBlock([components objectForKey:@"value"]);
    }
}


@end
