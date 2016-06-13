//
//  TweetCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetCell_PadingLeft kPaddingLeftWidth
#define kTweetCell_PadingTop (65 + 15)

#define kTweetCell_PadingBottom 10.0
#define kTweetCell_ContentWidth (kScreen_Width -kTweetCell_PadingLeft - kPaddingLeftWidth)
#define kTweetCell_LikeComment_Height 27.0
#define kTweetCell_LikeComment_Width 50.0
#define kTweetCell_LikeUserCCell_Height 26.0
#define kTweetCell_LikeUserCCell_Pading 10.0
#define kTweet_ContentFont [UIFont systemFontOfSize:16]
#define kTweet_ContentMaxHeight 200.0
#define kTweet_CommentFont [UIFont systemFontOfSize:14]
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweet_LikeUsersLineCount 7.0

#define kTweetCell_MaxCollectionNum (kDevice_Is_iPhone6Plus? 12: kDevice_Is_iPhone6? 10 : 9)

#import "TweetCell.h"
#import "TweetLikeUserCCell.h"
#import "TweetCommentCell.h"
#import "TweetCommentMoreCell.h"
#import "TweetMediaItemCCell.h"
#import "TweetMediaItemSingleCCell.h"
#import "Coding_NetAPIManager.h"
#import "MJPhotoBrowser.h"
#import "UICustomCollectionView.h"
#import "CodingShareView.h"
#import "TweetSendLocationDetailViewController.h"
#import "SendRewardManager.h"

@interface TweetCell ()
@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) NSArray *like_reward_users;
@property (assign, nonatomic) BOOL needTopView;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UILabel *timeLabel, *fromLabel;
@property (strong, nonatomic) UIButton *likeBtn, *commentBtn, *deleteBtn, *rewardBtn;
@property (strong, nonatomic) UIButton *locaitonBtn;
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) UICollectionView *likeUsersView;
@property (strong, nonatomic) UITableView *commentListView;
@property (strong, nonatomic) UIImageView *timeClockIconView, *commentOrLikeBeginImgView, *commentOrLikeSplitlineView, *fromPhoneIconView;
@end

@implementation TweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
        if (!_topView) {
            _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 15)];
            _topView.backgroundColor = [UIColor colorWithHexString:@"0xeeeeee"];
            [self.contentView addSubview:_topView];
        }
        
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 15 + CGRectGetMaxY(_topView.frame), 38, 38)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
        }
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(CGRectGetMaxX(self.ownerImgView.frame) + 10, 23 + CGRectGetMaxY(_topView.frame), 50, 20);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
//        if (!self.timeClockIconView) {
//            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 70, 25 + CGRectGetMaxY(_topView.frame), 12, 12)];
//            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
//            [self.contentView addSubview:self.timeClockIconView];
//        }
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.ownerNameBtn.frame), 0, kScreen_Width/2, 12)];
//            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 55, 23 + CGRectGetMaxY(_topView.frame), 55, 12)];
            self.timeLabel.font = kTweet_TimtFont;
//            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.timeLabel];
        }
        if (!self.contentLabel) {
            self.contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, kTweetCell_PadingTop, kTweetCell_ContentWidth, 20)];
            self.contentLabel.font = kTweet_ContentFont;
            self.contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            self.contentLabel.numberOfLines = 0;
            
            self.contentLabel.linkAttributes = kLinkAttributes;
            self.contentLabel.activeLinkAttributes = kLinkAttributesActive;
            self.contentLabel.delegate = self;
            [self.contentLabel addLongPressForCopy];
            [self.contentView addSubview:self.contentLabel];
        }
        if (!self.likeBtn) {
            CGRect frame = CGRectMake(kPaddingLeftWidth, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            self.likeBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:YES];
            [self.likeBtn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.likeBtn];
        }
        if (!self.rewardBtn) {
            CGRect frame = CGRectMake(kPaddingLeftWidth + kTweetCell_LikeComment_Width + 5, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            self.rewardBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:YES];
            [self.rewardBtn addTarget:self action:@selector(rewardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.rewardBtn];
        }
        if (!self.commentBtn) {
            CGRect frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- kTweetCell_LikeComment_Width, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            self.commentBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:NO];
            [self.commentBtn setImage:[UIImage imageNamed:@"tweet_btn_comment"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.commentBtn];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 2*kTweetCell_LikeComment_Width -5, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            [self.contentView addSubview:self.deleteBtn];
        }
        if (!self.locaitonBtn) {
            self.locaitonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.locaitonBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.locaitonBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.locaitonBtn.frame = CGRectMake(kTweetCell_PadingLeft, 0, kScreen_Width - kTweetCell_PadingLeft - kPaddingLeftWidth, 15);
            self.locaitonBtn.titleLabel.adjustsFontSizeToFitWidth = NO;
            self.locaitonBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.locaitonBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.locaitonBtn addTarget:self action:@selector(locationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.locaitonBtn];
        }
        if (!self.fromPhoneIconView) {
            self.fromPhoneIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 11, 11)];
            self.fromPhoneIconView.image = [UIImage imageNamed:@"little_phone_icon"];
            [self.contentView addSubview:self.fromPhoneIconView];
        }
        if (!self.fromLabel) {
            self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fromPhoneIconView.frame) + 5, 0, kScreen_Width/2, 15)];
            self.fromLabel.font = kTweet_TimtFont;
            self.fromLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.fromLabel];
        }
        
        if (!_commentOrLikeBeginImgView) {
            _commentOrLikeBeginImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft + 35, 0, 15, 7)];
            _commentOrLikeBeginImgView.image = [UIImage imageNamed:@"commentOrLikeBeginImg"];
            [self.contentView addSubview:_commentOrLikeBeginImgView];
        }
        
        if (!self.likeUsersView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.likeUsersView = [[UICollectionView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 35) collectionViewLayout:layout];
            self.likeUsersView.scrollEnabled = NO;
            [self.likeUsersView setBackgroundView:nil];
            [self.likeUsersView setBackgroundColor:kColorTableSectionBg];
            [self.likeUsersView registerClass:[TweetLikeUserCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser];
            self.likeUsersView.dataSource = self;
            self.likeUsersView.delegate = self;
            [self.contentView addSubview:self.likeUsersView];
        }
        
        if (!self.mediaView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 80) collectionViewLayout:layout];
            self.mediaView.scrollEnabled = NO;
            [self.mediaView setBackgroundView:nil];
            [self.mediaView setBackgroundColor:[UIColor clearColor]];
            [self.mediaView registerClass:[TweetMediaItemCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItem];
            [self.mediaView registerClass:[TweetMediaItemSingleCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItemSingle];
            self.mediaView.dataSource = self;
            self.mediaView.delegate = self;
            [self.contentView addSubview:self.mediaView];
        }
        
        
        if (!self.commentListView) {
            self.commentListView = [[UITableView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 20) style:UITableViewStylePlain];
            self.commentListView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.commentListView.scrollEnabled = NO;
            [self.commentListView setBackgroundView:nil];
            [self.commentListView setBackgroundColor:kColorTableSectionBg];
            [self.commentListView registerClass:[TweetCommentCell class] forCellReuseIdentifier:kCellIdentifier_TweetComment];
            [self.commentListView registerClass:[TweetCommentMoreCell class] forCellReuseIdentifier:kCellIdentifier_TweetCommentMore];
            self.commentListView.dataSource = self;
            self.commentListView.delegate = self;
            [self.contentView addSubview:self.commentListView];
        }
        if (!_commentOrLikeSplitlineView) {
            _commentOrLikeSplitlineView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 1)];
            _commentOrLikeSplitlineView.image = [UIImage imageNamed:@"splitlineImg"];
            [self.contentView addSubview:_commentOrLikeSplitlineView];
        }
    }
    return self;
}
- (void)setTweet:(Tweet *)tweet needTopView:(BOOL)needTopView{
    _tweet = tweet;
    _needTopView = needTopView;
    if (!_tweet) {
        return;
    }
    
    _like_reward_users = [_tweet like_reward_users];
    BOOL isMineTweet = [_tweet.owner.global_key isEqualToString:[Login curLoginUser].global_key];

    self.topView.hidden = !_needTopView;
    //owner头像
    __weak __typeof(self)weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    //owner姓名
    [self.ownerNameBtn setUserTitle:_tweet.owner.name font:[UIFont systemFontOfSize:17] maxWidth:(kTweetCell_ContentWidth-85)];
    //发出冒泡的时间
    self.timeLabel.text = [_tweet.created_at stringDisplay_HHmm];
//    [self.timeLabel setLongString:[_tweet.created_at stringDisplay_HHmm] withVariableWidth:kScreen_Width/2];
//    CGFloat timeLabelX = kScreen_Width - kPaddingLeftWidth - CGRectGetWidth(self.timeLabel.frame);
//    [self.timeLabel setX:timeLabelX];
//    [self.timeClockIconView setX:timeLabelX-15];
    
    CGFloat centerY = 15 + 15 + CGRectGetHeight(_ownerImgView.frame)/2;
    CGFloat curBottomY = _needTopView? 0: -15;
    centerY += curBottomY;
    
    [self.topView setY:curBottomY];
    [self.ownerImgView setCenterY:centerY];
//    [self.ownerNameBtn setCenterY:centerY];
//    [self.timeClockIconView setCenterY:centerY];
//    [self.timeLabel setCenterY:centerY];
    [self.ownerNameBtn setY:CGRectGetMinY(self.ownerImgView.frame)];
    [self.timeLabel setY:CGRectGetMaxY(self.ownerImgView.frame) - CGRectGetHeight(self.timeLabel.frame)];
    
    curBottomY += kTweetCell_PadingTop;
    
    //owner冒泡text内容
    [self.contentLabel setY:curBottomY];
    [self.contentLabel setLongString:_tweet.content withFitWidth:kTweetCell_ContentWidth maxHeight:kTweet_ContentMaxHeight];
    for (HtmlMediaItem *item in _tweet.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    curBottomY += [TweetCell contentLabelHeightWithTweet:_tweet];
    //图片缩略图展示
    if (_tweet.htmlMedia.imageItems.count > 0) {
        
        CGFloat mediaHeight = [TweetCell contentMediaHeightWithTweet:_tweet];
        CGFloat mediaWidth = _tweet.htmlMedia.imageItems.count == 4? kTweetCell_ContentWidth - [TweetMediaItemCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject].width - 3: kTweetCell_ContentWidth;
        [self.mediaView setFrame:CGRectMake(kTweetCell_PadingLeft, curBottomY, mediaWidth, mediaHeight)];
        [self.mediaView reloadData];
        self.mediaView.hidden = NO;
        curBottomY += mediaHeight;
    }else{
        if (self.mediaView) {
            self.mediaView.hidden = YES;
        }
    }
    
    //地址&设备小尾巴
    if (_tweet.location.length > 0 || _tweet.device.length > 0) {
        if (_tweet.location.length > 0) {
            [self.locaitonBtn setTitle:_tweet.location forState:UIControlStateNormal];
            [self.locaitonBtn setY:curBottomY];
            curBottomY += _tweet.device.length > 0? 20: 15;
        }
        if (_tweet.device.length > 0) {
            self.fromLabel.text = [NSString stringWithFormat:@"来自 %@", _tweet.device];
            [self.fromLabel setY:curBottomY];
            [self.fromPhoneIconView setCenterY:self.fromLabel.centerY];
            curBottomY += 15;
        }
        curBottomY += 15;
    }
    self.locaitonBtn.hidden = _tweet.location.length <= 0;
    self.fromLabel.hidden = self.fromPhoneIconView.hidden = _tweet.device.length <= 0;
    
    //喜欢&评论 按钮
    curBottomY += 5;
    curBottomY += 5;
    self.likeBtn.y = self.rewardBtn.y = self.commentBtn.y = curBottomY;
    [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_btn_liked":@"tweet_btn_like")] forState:UIControlStateNormal];
    [self.likeBtn setTitle:_tweet.likes.stringValue forState:UIControlStateNormal];
    [self.rewardBtn setImage:[UIImage imageNamed:(_tweet.rewarded.boolValue? @"tweet_btn_rewarded": @"tweet_btn_reward")] forState:UIControlStateNormal];
    [self.rewardBtn setTitle:_tweet.rewards.stringValue forState:UIControlStateNormal];
    [self.commentBtn setTitle:_tweet.comments.stringValue forState:UIControlStateNormal];
    
    [self.deleteBtn setY:curBottomY];
    self.deleteBtn.hidden = !isMineTweet;
    
    curBottomY += kTweetCell_LikeComment_Height;
    curBottomY += [TweetCell likeCommentBtn_BottomPadingWithTweet:_tweet];
    
    if ([_tweet hasLikesOrRewards] || _tweet.numOfComments > 0) {
        [_commentOrLikeBeginImgView setY:(curBottomY - CGRectGetHeight(_commentOrLikeBeginImgView.frame) + 1)];
        _commentOrLikeBeginImgView.hidden = NO;
    }else{
        _commentOrLikeBeginImgView.hidden = YES;
    }
    
    //点赞的人_列表
    //    可有可无
    if ([_tweet hasLikesOrRewards]) {
        CGFloat likeUsersHeight = [TweetCell likeUsersHeightWithTweet:_tweet];
        [self.likeUsersView setFrame:CGRectMake(kTweetCell_PadingLeft, curBottomY, kTweetCell_ContentWidth, likeUsersHeight)];
        [self.likeUsersView reloadData];
        self.likeUsersView.hidden = NO;
        curBottomY += likeUsersHeight;
    }else{
        if (self.likeUsersView) {
            self.likeUsersView.hidden = YES;
        }
    }
    //评论与赞的分割线
    if ([_tweet hasLikesOrRewards] && _tweet.numOfComments > 0) {
        [_commentOrLikeSplitlineView setY:(curBottomY -1)];
        _commentOrLikeSplitlineView.hidden = NO;
    }else{
        _commentOrLikeSplitlineView.hidden = YES;
    }
    
    //评论的人_列表
    //    可有可无
    if (_tweet.numOfComments > 0) {
        CGFloat commentListViewHeight = [TweetCell commentListViewHeightWithTweet:_tweet];
        [self.commentListView setFrame:CGRectMake(kTweetCell_PadingLeft, floor(2*curBottomY)/2.0, kTweetCell_ContentWidth, commentListViewHeight)];
        [self.commentListView reloadData];
        self.commentListView.hidden = NO;
    }else{
        if (self.commentListView) {
            self.commentListView.hidden = YES;
        }
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj needTopView:(BOOL)needTopView{
    Tweet *tweet = (Tweet *)obj;
    CGFloat cellHeight = 0;
    cellHeight += needTopView? 0: -15;
    cellHeight +=  kTweetCell_PadingTop;
    cellHeight += [self contentLabelHeightWithTweet:tweet];
    cellHeight += [self contentMediaHeightWithTweet:tweet];
    cellHeight += [self locationAndDeviceHeightWithTweet:tweet];
    cellHeight += 5+ kTweetCell_LikeComment_Height;
    cellHeight += [TweetCell likeCommentBtn_BottomPadingWithTweet:tweet];
    cellHeight += [TweetCell likeUsersHeightWithTweet:tweet];
    cellHeight += [TweetCell commentListViewHeightWithTweet:tweet];
    cellHeight += 15;
    return ceilf(cellHeight);
}

+ (CGFloat)contentLabelHeightWithTweet:(Tweet *)tweet{
    CGFloat height = 0;
    if (tweet.content.length > 0) {
        height += MIN(kTweet_ContentMaxHeight, [tweet.content getHeightWithFont:kTweet_ContentFont constrainedToSize:CGSizeMake(kTweetCell_ContentWidth, CGFLOAT_MAX)]);
        height += 15;
    }
    return height;
}

+ (CGFloat)contentMediaHeightWithTweet:(Tweet *)tweet{
    CGFloat contentMediaHeight = 0;
    NSInteger mediaCount = tweet.htmlMedia.imageItems.count;
    if (mediaCount > 0) {
        HtmlMediaItem *curMediaItem = tweet.htmlMedia.imageItems.firstObject;
        contentMediaHeight = (mediaCount == 1)?
        [TweetMediaItemSingleCCell ccellSizeWithObj:curMediaItem].height:
        ceilf((float)mediaCount/3)*([TweetMediaItemCCell ccellSizeWithObj:curMediaItem].height+3.0) - 3.0;
        contentMediaHeight += 15;//padding
    }
    return contentMediaHeight;
}

+ (CGFloat)likeCommentBtn_BottomPadingWithTweet:(Tweet *)tweet{
    if (tweet &&
        ([tweet hasLikesOrRewards]
         ||tweet.comments.intValue> 0)){
            return 15.0;
        }else{
            return 0;
        }
}

+ (CGFloat)locationAndDeviceHeightWithTweet:(Tweet *)tweet{
    CGFloat height = 0;
    if (tweet.location.length > 0 || tweet.device.length > 0) {
        if (tweet.location.length > 0) {
            height += tweet.device.length > 0? 20: 15;
        }
        if (tweet.device.length > 0) {
            height += 15;
        }
        height += 15;
    }
    return height;
}


+ (CGFloat)likeUsersHeightWithTweet:(Tweet *)tweet{
    CGFloat likeUsersHeight = 0;
    if ([tweet hasLikesOrRewards]) {
        likeUsersHeight = 45;
//        +30*(ceilf([tweet.like_users count]/kTweet_LikeUsersLineCount)-1);
    }
    return likeUsersHeight;
}

+ (CGFloat)commentListViewHeightWithTweet:(Tweet *)tweet{
    if (!tweet) {
        return 0;
    }
    CGFloat commentListViewHeight = 0;

    NSInteger numOfComments = tweet.numOfComments;
    BOOL hasMoreComments = tweet.hasMoreComments;
    
    for (int i = 0; i < numOfComments; i++) {
        if (i == numOfComments-1 && hasMoreComments) {
            commentListViewHeight += [TweetCommentMoreCell cellHeight];
        }else{
            Comment *curComment = [tweet.comment_list objectAtIndex:i];
            commentListViewHeight += [TweetCommentCell cellHeightWithObj:curComment];
        }
    }
    return commentListViewHeight;
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (collectionView == _mediaView) {
        row = _tweet.htmlMedia.imageItems.count;
    }else{
        row = MIN(kTweetCell_MaxCollectionNum, [_tweet hasMoreLikesOrRewards]? _like_reward_users.count + 1: _like_reward_users.count);
    }
    return row;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _mediaView) {
        HtmlMediaItem *curMediaItem = [_tweet.htmlMedia.imageItems objectAtIndex:indexPath.row];
        if (_tweet.htmlMedia.imageItems.count == 1) {
            TweetMediaItemSingleCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItemSingle forIndexPath:indexPath];
            ccell.curMediaItem = curMediaItem;
            ccell.refreshSingleCCellBlock = ^(){
                if (_cellRefreshBlock) {
                    _cellRefreshBlock();
                }
            };
            return ccell;
        }else{
            TweetMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItem forIndexPath:indexPath];
            ccell.curMediaItem = curMediaItem;
            return ccell;
        }
    }else{
        TweetLikeUserCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser forIndexPath:indexPath];
        if (indexPath.row >= kTweetCell_MaxCollectionNum -1
            || indexPath.row >= _like_reward_users.count) {
            [ccell configWithUser:nil rewarded:NO];
        }else{
            User *curUser = [_like_reward_users objectAtIndex:indexPath.row];
            [ccell configWithUser:curUser rewarded:[_tweet rewardedBy:curUser]];
        }
        return ccell;
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize itemSize;
    if (collectionView == _mediaView) {
        if (_tweet.htmlMedia.imageItems.count == 1) {
            itemSize = [TweetMediaItemSingleCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
        }else{
            itemSize = [TweetMediaItemCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
        }
    }else{
        itemSize = CGSizeMake(kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height);
    }
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets insetForSection;
    if (collectionView == _mediaView) {
        if (_tweet.htmlMedia.imageItems.count == 1) {
            CGSize itemSize = [TweetMediaItemSingleCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
            insetForSection = UIEdgeInsetsMake(0, 0, 0, kTweetCell_ContentWidth - itemSize.width);
        }else{
            insetForSection = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }else{
        insetForSection = UIEdgeInsetsMake(kTweetCell_LikeUserCCell_Pading, 5, kTweetCell_LikeUserCCell_Pading, 5);
    }
    return insetForSection;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    if (collectionView == _mediaView) {
        return 3.0;
    }else{
        return kTweetCell_LikeUserCCell_Pading;
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    if (collectionView == _mediaView) {
        return 2.0;
    }else{
        return kTweetCell_LikeUserCCell_Pading/2;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == _mediaView) {
        //        显示大图
        int count = (int)_tweet.htmlMedia.imageItems.count;
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i<count; i++) {
            HtmlMediaItem *imageItem = [_tweet.htmlMedia.imageItems objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
            [photos addObject:photo];
        }
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show];
    }else{
        if (indexPath.row >= kTweetCell_MaxCollectionNum -1
            || indexPath.row >= _like_reward_users.count) {
            if (_moreLikersBtnClickedBlock) {
                _moreLikersBtnClickedBlock(_tweet);
            }
        }else{
            User *curUser = [_like_reward_users objectAtIndex:indexPath.row];
            if (_userBtnClickedBlock) {
                _userBtnClickedBlock(curUser);
            }
        }
    }
}

#pragma mark Table M comments
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tweet.numOfComments;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= _tweet.numOfComments-1 && _tweet.hasMoreComments) {
        TweetCommentMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetCommentMore forIndexPath:indexPath];
        cell.commentNum = _tweet.comments;
        return cell;
    }else{
        TweetCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_TweetComment forIndexPath:indexPath];
        Comment *curComment = [_tweet.comment_list objectAtIndex:indexPath.row];
        [cell configWithComment:curComment topLine:(indexPath.row != 0)];
        cell.commentLabel.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = 0;
    if (indexPath.row >= _tweet.numOfComments-1 && _tweet.hasMoreComments) {
        cellHeight = [TweetCommentMoreCell cellHeight];
    }else{
        Comment *curComment = [_tweet.comment_list objectAtIndex:indexPath.row];
        cellHeight = [TweetCommentCell cellHeightWithObj:curComment];
    }
    return cellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row >= _tweet.numOfComments-1 && _tweet.hasMoreComments) {
        DebugLog(@"More Comment");
        if (_goToDetailTweetBlock) {
            _goToDetailTweetBlock(_tweet);
        }
    }else{
        if (_commentClickedBlock) {
            _commentClickedBlock(_tweet, indexPath.row, [tableView cellForRowAtIndexPath:indexPath]);
        }
    }
}
#pragma mark Table Copy
//
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _tweet.numOfComments-1 && _tweet.hasMoreComments) {
        return NO;
    }
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        Comment *curComment = [_tweet.comment_list objectAtIndex:indexPath.row];
        [UIPasteboard generalPasteboard].string = curComment.content? curComment.content: @"";
    }
}

#pragma mark Btn M
- (void)likeBtnClicked:(id)sender{
    BOOL preLiked = _tweet.liked.boolValue;
    //重新加载likes
    [_tweet changeToLiked:[NSNumber numberWithBool:!preLiked]];
    if (_cellRefreshBlock) {
        _cellRefreshBlock();
    }
    //开始动画
    if (preLiked) {
        [self.likeBtn setImage:[UIImage imageNamed:@"tweet_btn_like"] forState:UIControlStateNormal];
    }else{
        [self.likeBtn animateToImage:@"tweet_btn_liked"];
    }
    //发起请求
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoLike_WithObj:_tweet andBlock:^(id data, NSError *error) {
        if (!data) {//如果请求失败，就再改回来
            [_tweet changeToLiked:[NSNumber numberWithBool:preLiked]];
            if (_cellRefreshBlock) {
                _cellRefreshBlock();
            }
            [self.likeBtn setImage:[UIImage imageNamed:preLiked? @"tweet_btn_liked" : @"tweet_btn_like"] forState:UIControlStateNormal];
        }
    }];
}
- (void)commentBtnClicked:(id)sender{
    if (_commentClickedBlock) {
        _commentClickedBlock(_tweet, -1, sender);
    }
}
- (void)deleteBtnClicked:(UIButton *)sender{
    if (_deleteClickedBlock) {
        _deleteClickedBlock(_tweet, _outTweetsIndex);
    }
}

- (void)userBtnClicked{
    if (_userBtnClickedBlock) {
        _userBtnClickedBlock(_tweet.owner);
    }
}
- (void)locationBtnClicked:(id)sender{
    TweetSendLocationDetailViewController *vc = [[TweetSendLocationDetailViewController alloc]init];
    vc.tweet = _tweet;
    if (vc.tweet.coord.length > 0) {
        [[BaseViewController presentingVC].navigationController pushViewController:vc animated:YES];
        
    }
}
- (void)rewardBtnClicked:(id)sender{
    @weakify(self);
    [SendRewardManager handleTweet:_tweet completion:^(Tweet *curTweet, BOOL sendSucess) {
        @strongify(self);
        if (self.cellRefreshBlock) {
            self.cellRefreshBlock();
        }
    }];
}
#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    if (_mediaItemClickedBlock) {
        _mediaItemClickedBlock([components objectForKey:@"value"]);
    }
}

@end
