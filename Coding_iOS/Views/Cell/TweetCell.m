//
//  TweetCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetCell_PadingLeft 50.0
#define kTweetCell_PadingTop 45.0
#define kTweetCell_PadingBottom 10.0
#define kTweetCell_ContentWidth (kScreen_Width -kTweetCell_PadingLeft - kPaddingLeftWidth)
#define kTweetCell_LikeComment_Height 25.0
#define kTweetCell_LikeComment_Width 50.0
#define kTweetCell_LikeUserCCell_Height 25.0
#define kTweetCell_LikeUserCCell_Pading 10.0

#define kTweet_ContentFont [UIFont systemFontOfSize:16]
#define kTweet_CommentFont [UIFont systemFontOfSize:14]
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweet_LikeUsersLineCount 7.0
#define kTweet_CommentListBackColor [UIColor colorWithHexString:@"0xedebec"]

#define kCCellIdentifier_TweetLikeUser @"TweetLikeUserCCell"
#define kCCellIdentifier_TweetMediaItem @"TweetMediaItemCCell"
#define kCCellIdentifier_TweetMediaItemSingle @"TweetMediaItemSingleCCell"
#define kCellIdentifier_TweetComment @"TweetCommentCell"
#define kCellIdentifier_TweetCommentMore @"TweetCommentMoreCell"

#import "TweetCell.h"
#import "TweetLikeUserCCell.h"
#import "TweetCommentCell.h"
#import "TweetCommentMoreCell.h"
#import "TweetMediaItemCCell.h"
#import "TweetMediaItemSingleCCell.h"
#import "Coding_NetAPIManager.h"
#import "MJPhotoBrowser.h"
#import "UICustomCollectionView.h"

@interface TweetCell ()

@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UILabel *timeLabel, *fromLabel;
@property (strong, nonatomic) UIButton *likeBtn, *commentBtn, *deleteBtn;
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) UICollectionView *likeUsersView;
@property (strong, nonatomic) UITableView *commentListView;
@property (strong, nonatomic) UIImageView *timeClockIconView, *commentOrLikeBeginImgView, *commentOrLikeSplitlineView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;
@end

@implementation TweetCell

- (void)setTweet:(Tweet *)tweet{
    if (_tweet != tweet) {
        _tweet = tweet;
    }
    if (_imageViewsDict) {
        [_imageViewsDict removeAllObjects];
    }else{
        _imageViewsDict = [[NSMutableDictionary alloc] init];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(10, 10, 33, 33)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
        }
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(kTweetCell_PadingLeft, 15, 50, 20);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
        if (!self.timeClockIconView) {
            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 70, 17, 12, 12)];
            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:self.timeClockIconView];
        }
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 55, 15, 55, 12)];
            self.timeLabel.font = kTweet_TimtFont;
            self.timeLabel.textAlignment = NSTextAlignmentRight;
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
        
        if (!self.commentBtn) {
            self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.commentBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- kTweetCell_LikeComment_Width, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            [self.commentBtn setImage:[UIImage imageNamed:@"tweet_comment_btn"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.commentBtn];
        }
        if (!self.likeBtn) {
            self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.likeBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 2*kTweetCell_LikeComment_Width -5, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            [self.likeBtn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.likeBtn];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 3*kTweetCell_LikeComment_Width -5, 0, kTweetCell_LikeComment_Width, kTweetCell_LikeComment_Height);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

            [self.contentView addSubview:self.deleteBtn];
        }
        if (!self.fromLabel) {
            self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 100, 15)];
            self.fromLabel.font = kTweet_TimtFont;
            self.fromLabel.minimumScaleFactor = 0.50;
            self.fromLabel.adjustsFontSizeToFitWidth = YES;
            self.fromLabel.textAlignment = NSTextAlignmentLeft;
            self.fromLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.fromLabel];
        }
        
        if (!_commentOrLikeBeginImgView) {
            _commentOrLikeBeginImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft +20, 0, 15, 7)];
            _commentOrLikeBeginImgView.image = [UIImage imageNamed:@"commentOrLikeBeginImg"];
            [self.contentView addSubview:_commentOrLikeBeginImgView];
        }
        
        if (!self.likeUsersView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.likeUsersView = [[UICollectionView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 35) collectionViewLayout:layout];
            self.likeUsersView.scrollEnabled = NO;
            [self.likeUsersView setBackgroundView:nil];
            [self.likeUsersView setBackgroundColor:kTweet_CommentListBackColor];
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
            [self.commentListView setBackgroundColor:kTweet_CommentListBackColor];
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

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_tweet) {
        return;
    }
    //owner头像
    __weak __typeof(self)weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    //owner姓名
    [self.ownerNameBtn setUserTitle:_tweet.owner.name font:[UIFont systemFontOfSize:17] maxWidth:(kTweetCell_ContentWidth-85)];
    //owner冒泡text内容
    [self.contentLabel setWidth:kTweetCell_ContentWidth];
    self.contentLabel.text = _tweet.content;
    [self.contentLabel sizeToFit];
//    [self.contentLabel setLongString:_tweet.content withFitWidth:kTweetCell_ContentWidth];
    for (HtmlMediaItem *item in _tweet.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    CGFloat curBottomY = kTweetCell_PadingTop +[TweetCell contentLabelHeightWithTweet:_tweet] +5;
    //图片缩略图展示
    if (_tweet.htmlMedia.imageItems.count > 0) {
        
        CGFloat mediaHeight = [TweetCell contentMediaHeightWithTweet:_tweet];
        [self.mediaView setFrame:CGRectMake(kTweetCell_PadingLeft, curBottomY, kTweetCell_ContentWidth, mediaHeight)];
        [self.mediaView reloadData];
        self.mediaView.hidden = NO;
        
        curBottomY += mediaHeight;
    }else{
        if (self.mediaView) {
            self.mediaView.hidden = YES;
        }
    }
    
    //发出冒泡的时间
    [self.timeLabel setLongString:[_tweet.created_at stringTimesAgo] withVariableWidth:kScreen_Width/2];
    CGFloat timeLabelX = kScreen_Width - kPaddingLeftWidth - CGRectGetWidth(self.timeLabel.frame);
    [self.timeLabel setX:timeLabelX];
    [self.timeClockIconView setX:timeLabelX-15];
    
    curBottomY += 10;
    //喜欢&评论 按钮
    [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_liked_btn":@"tweet_like_btn")] forState:UIControlStateNormal];
    [self.likeBtn setY:curBottomY];
    [self.commentBtn setY:curBottomY];
    BOOL isMineTweet = _tweet.owner.id.longValue == [Login curLoginUser].id.longValue;
    if (isMineTweet) {
        [self.deleteBtn setY:curBottomY];
        self.deleteBtn.hidden = NO;
    }else{
        self.deleteBtn.hidden = YES;
    }
    if (_tweet.device && _tweet.device.length > 0) {
        self.fromLabel.text = [NSString stringWithFormat:@"来自 %@", _tweet.device];
        self.fromLabel.frame = CGRectMake(kTweetCell_PadingLeft, curBottomY +5,
                                          (isMineTweet? (kScreen_Width - kTweetCell_PadingLeft- kPaddingLeftWidth- 3*kTweetCell_LikeComment_Width- 10):
                                           (kScreen_Width - kTweetCell_PadingLeft- kPaddingLeftWidth- 2*kTweetCell_LikeComment_Width- 10)), 15);
        self.fromLabel.hidden = NO;
    }else{
        self.fromLabel.hidden = YES;
    }
    
    curBottomY += kTweetCell_LikeComment_Height;
    curBottomY += [TweetCell likeCommentBtn_BottomPadingWithTweet:_tweet];
    
    
    if (_tweet.numOfLikers > 0 || _tweet.numOfComments > 0) {
        [_commentOrLikeBeginImgView setY:(curBottomY - CGRectGetHeight(_commentOrLikeBeginImgView.frame))];
        _commentOrLikeBeginImgView.hidden = NO;
    }else{
        _commentOrLikeBeginImgView.hidden = YES;
    }
    
    //点赞的人_列表
    //    可有可无
    if (_tweet.numOfLikers > 0) {
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
    if (_tweet.numOfLikers > 0 && _tweet.numOfComments > 0) {
        [_commentOrLikeSplitlineView setY:(curBottomY -1)];
        _commentOrLikeSplitlineView.hidden = NO;
    }else{
        _commentOrLikeSplitlineView.hidden = YES;
    }
    
    //评论的人_列表
    //    可有可无
    if (_tweet.numOfComments > 0) {
        CGFloat commentListViewHeight = [TweetCell commentListViewHeightWithTweet:_tweet];
        [self.commentListView setFrame:CGRectMake(kTweetCell_PadingLeft, curBottomY, kTweetCell_ContentWidth, commentListViewHeight)];
        [self.commentListView reloadData];
        self.commentListView.hidden = NO;
    }else{
        if (self.commentListView) {
            self.commentListView.hidden = YES;
        }
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    Tweet *tweet = (Tweet *)obj;
    CGFloat cellHeight = 0;
    if (tweet.likes.integerValue > 0 || tweet.comments.integerValue > 0) {
        cellHeight = 6;
    }else{
        cellHeight = 3;
    }
    cellHeight += 10;
    cellHeight += kTweetCell_PadingTop;
    cellHeight += [TweetCell contentLabelHeightWithTweet:tweet];
    cellHeight += [TweetCell contentMediaHeightWithTweet:tweet];
    cellHeight += kTweetCell_LikeComment_Height;
    cellHeight += [TweetCell likeCommentBtn_BottomPadingWithTweet:tweet];
    cellHeight += [TweetCell likeUsersHeightWithTweet:tweet];
    cellHeight += [TweetCell commentListViewHeightWithTweet:tweet];
    cellHeight += kTweetCell_PadingBottom;
    return cellHeight;
}

+ (CGFloat)contentLabelHeightWithTweet:(Tweet *)tweet{
    return [tweet.content getHeightWithFont:kTweet_ContentFont constrainedToSize:CGSizeMake(kTweetCell_ContentWidth, CGFLOAT_MAX)];
}

+ (CGFloat)contentMediaHeightWithTweet:(Tweet *)tweet{
    CGFloat contentMediaHeight = 0;
    NSInteger mediaCount = tweet.htmlMedia.imageItems.count;
    if (mediaCount > 0) {
        HtmlMediaItem *curMediaItem = tweet.htmlMedia.imageItems.firstObject;
        contentMediaHeight = (mediaCount == 1)?
        [TweetMediaItemSingleCCell ccellSizeWithObj:curMediaItem].height:
        ceilf((float)mediaCount/3)*([TweetMediaItemCCell ccellSizeWithObj:curMediaItem].height+kTweetCell_LikeUserCCell_Pading) - kTweetCell_LikeUserCCell_Pading;
    }
    return contentMediaHeight;
}

+ (CGFloat)likeCommentBtn_BottomPadingWithTweet:(Tweet *)tweet{
    if (tweet &&
        (tweet.likes.intValue > 0
         ||tweet.likes.intValue> 0)){
            return 5.0;
        }else{
            return 0;
        }
}

+ (CGFloat)likeUsersHeightWithTweet:(Tweet *)tweet{
    CGFloat likeUsersHeight = 0;
    if (tweet.likes.intValue > 0) {
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
        row = _tweet.numOfLikers;
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
                if (_refreshSingleCCellBlock) {
                    _refreshSingleCCellBlock();
                }
            };
            [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
            return ccell;
        }else{
            TweetMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItem forIndexPath:indexPath];
            ccell.curMediaItem = curMediaItem;
            [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
            return ccell;
        }
    }else{
        TweetLikeUserCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser forIndexPath:indexPath];
        if (indexPath.row >= _tweet.numOfLikers-1 && _tweet.hasMoreLikers) {
            [ccell configWithUser:nil likesNum:_tweet.likes];
        }else{
            User *curUser = [_tweet.like_users objectAtIndex:indexPath.row];
            [ccell configWithUser:curUser likesNum:nil];
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
    return kTweetCell_LikeUserCCell_Pading;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kTweetCell_LikeUserCCell_Pading/2;
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
            photo.srcImageView = [_imageViewsDict objectForKey:[NSIndexPath indexPathForItem:i inSection:0]]; // 来源于哪个UIImageView
            [photos addObject:photo];
        }
        
        // 2.显示相册
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        browser.photos = photos; // 设置所有的图片
        [browser show];
    }else{
        if (indexPath.row >= _tweet.numOfLikers-1 && _tweet.hasMoreLikers) {
            if (_moreLikersBtnClickedBlock) {
                _moreLikersBtnClickedBlock(_tweet);
            }
        }else{
            User *curUser = [_tweet.like_users objectAtIndex:indexPath.row];
            DebugLog(@"%@", curUser.name);
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
        NSLog(@"More Comment");
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
        [UIPasteboard generalPasteboard].string = curComment.content;
    }
}

#pragma mark Btn M
- (void)likeBtnClicked:(id)sender{
    DebugLog(@"likeBtnClicked");
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoLike_WithObj:_tweet andBlock:^(id data, NSError *error) {
        if (data) {
            [_tweet changeToLiked:[NSNumber numberWithBool:!_tweet.liked.boolValue]];
            [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_liked_btn":@"tweet_like_btn")] forState:UIControlStateNormal];
            if (_likeBtnClickedBlock) {
                _likeBtnClickedBlock(_tweet);
            }
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
#pragma mark TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    DebugLog(@"%@", components.description);
    if (_mediaItemClickedBlock) {
        _mediaItemClickedBlock([components objectForKey:@"value"]);
    }
}

@end
