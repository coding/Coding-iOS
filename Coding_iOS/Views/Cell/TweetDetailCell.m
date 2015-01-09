//
//  TweetDetailCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetDetailCell_PadingLeft 50.0
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweetDetailCell_LikeComment_Height 25.0
#define kTweetDetailCell_LikeComment_Width 50.0
#define kTweetDetailCell_ContentWidth (kScreen_Width - 2*kPaddingLeftWidth)
#define kCCellIdentifier_TweetLikeUser @"TweetLikeUserCCell"
#define kTweetDetailCell_PadingTop 55.0
#define kTweetDetailCell_PadingBottom 10.0
#define kTweetDetailCell_LikeUserCCell_Height 25.0
#define kTweetDetailCell_LikeUserCCell_Pading 10.0
#define kTweetDetailCell_LikeNumMax 10



#import "TweetDetailCell.h"
#import "UICustomCollectionView.h"
#import "TweetLikeUserCCell.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"



@interface TweetDetailCell ()
@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UILabel *timeLabel, *fromLabel;
@property (strong, nonatomic) UIButton *likeBtn, *commentBtn, *deleteBtn;
@property (strong, nonatomic) UICustomCollectionView *likeUsersView;
@property (strong, nonatomic) UIImageView *timeClockIconView;
@property (strong, nonatomic) UIWebView *tweetContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
@implementation TweetDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        //        self.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, 33, 33)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
        }
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(kTweetDetailCell_PadingLeft, 15, 50, 20);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
        if (!self.timeClockIconView) {
            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 85, 17, 12, 12)];
            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:self.timeClockIconView];
        }
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 70, 15, 70, 12)];
            self.timeLabel.font = kTweet_TimtFont;
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.timeLabel];
        }

        if (!self.commentBtn) {
            self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.commentBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- kTweetDetailCell_LikeComment_Width, 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            [self.commentBtn setImage:[UIImage imageNamed:@"tweet_comment_btn"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.commentBtn];
        }
        if (!self.likeBtn) {
            self.likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.likeBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 2*kTweetDetailCell_LikeComment_Width- 5 , 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            [self.likeBtn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.likeBtn];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 3*kTweetDetailCell_LikeComment_Width- 5 , 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:self.deleteBtn];
        }
        if (!self.fromLabel) {
            self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 120, 15)];
            self.fromLabel.font = kTweet_TimtFont;
            self.fromLabel.minimumScaleFactor = 0.50;
            self.fromLabel.adjustsFontSizeToFitWidth = YES;
            self.fromLabel.textAlignment = NSTextAlignmentLeft;
            self.fromLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.fromLabel];
        }
        if (!self.likeUsersView) {
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            self.likeUsersView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 35) collectionViewLayout:layout];
            self.likeUsersView.scrollEnabled = NO;
            [self.likeUsersView setBackgroundView:nil];
            [self.likeUsersView setBackgroundColor:[UIColor clearColor]];
            [self.likeUsersView registerClass:[TweetLikeUserCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser];
            self.likeUsersView.dataSource = self;
            self.likeUsersView.delegate = self;
            [self.likeUsersView addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xdddddd"]];
            [self.contentView addSubview:self.likeUsersView];
        }
        if (!self.tweetContentView) {
            self.tweetContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kTweetDetailCell_PadingTop, kTweetDetailCell_ContentWidth, 1)];
            self.tweetContentView.delegate = self;
            self.tweetContentView.scrollView.scrollEnabled = NO;
            self.tweetContentView.scrollView.scrollsToTop = NO;
            self.tweetContentView.scrollView.bounces = NO;
            self.tweetContentView.backgroundColor = [UIColor clearColor];
            self.tweetContentView.opaque = NO;
            [self.contentView addSubview:self.tweetContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [_activityIndicator setCenter:CGPointMake(kPaddingLeftWidth + kTweetDetailCell_ContentWidth/2, kTweetDetailCell_PadingTop+CGRectGetHeight(_activityIndicator.bounds)/2)];
            [self.contentView addSubview:_activityIndicator];
        }

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet{
    if (tweet) {
        _tweet = tweet;
    }
    
    //owner头像
    __weak __typeof(self)weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    //owner姓名
//    [self.ownerNameBtn setUserTitle:_tweet.owner.name];
    [self.ownerNameBtn setUserTitle:_tweet.owner.name font:[UIFont systemFontOfSize:17] maxWidth:(kScreen_Width- kTweetDetailCell_PadingLeft - 85)];

    //发出冒泡的时间
    [self.timeLabel setLongString:[_tweet.created_at stringTimesAgo] withVariableWidth:kScreen_Width/2];
    CGFloat timeLabelX = kScreen_Width - kPaddingLeftWidth - CGRectGetWidth(self.timeLabel.frame);
    [self.timeLabel setX:timeLabelX];
    [self.timeClockIconView setX:timeLabelX-15];
    
    //owner冒泡text内容
    [self.tweetContentView setHeight:_tweet.contentHeight];
    if (!self.tweetContentView.isLoading) {
        [_activityIndicator startAnimating];
        [self.tweetContentView loadHTMLString:[WebContentManager bubblePatternedWithContent:_tweet.htmlMedia.contentOrigional] baseURL:nil];
    }
    
    CGFloat curBottomY = kTweetDetailCell_PadingTop +[[self class] contentHeightWithTweet:_tweet];
    curBottomY += 10;
    //喜欢&评论 按钮
    [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_liked_btn":@"tweet_like_btn")] forState:UIControlStateNormal];
    [self.likeBtn setY:curBottomY];
    [self.commentBtn setY:curBottomY];
    if (_tweet.owner.id.longValue == [Login curLoginUser].id.longValue) {
        [self.deleteBtn setY:curBottomY];
        self.deleteBtn.hidden = NO;
    }else{
        self.deleteBtn.hidden = YES;
    }
    if (_tweet.device && _tweet.device.length > 0) {
        self.fromLabel.text = [NSString stringWithFormat:@"来自 %@", _tweet.device];
        [self.fromLabel setY:curBottomY +5];
        self.fromLabel.hidden = NO;
    }else{
        self.fromLabel.hidden = YES;
    }
    
    curBottomY += kTweetDetailCell_LikeComment_Height;
    curBottomY += [[self class] likeCommentBtn_BottomPadingWithTweet:_tweet];
    
    
    //点赞的人_列表
    //    可有可无
    if (_tweet.likes.intValue > 0) {
        CGFloat likeUsersHeight = [[self class] likeUsersHeightWithTweet:_tweet];
        [self.likeUsersView setFrame:CGRectMake(0, curBottomY, kScreen_Width, likeUsersHeight)];
        [self.likeUsersView reloadData];
        self.likeUsersView.hidden = NO;
    }else{
        if (self.likeUsersView) {
            self.likeUsersView.hidden = YES;
        }
    }
}

#pragma mark cell Height

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if (obj && [obj isKindOfClass:[Tweet class]]) {
        Tweet *tweet = (Tweet *)obj;
        cellHeight += kTweetDetailCell_PadingTop;
        cellHeight += [[self class] contentHeightWithTweet:tweet];
        cellHeight += 10;
        cellHeight += kTweetDetailCell_LikeComment_Height;
        cellHeight += [[self class] likeCommentBtn_BottomPadingWithTweet:tweet];
        cellHeight += [[self class] likeUsersHeightWithTweet:tweet];
        cellHeight += kTweetDetailCell_PadingBottom;
    }
    return cellHeight;
}

+ (CGFloat)contentHeightWithTweet:(Tweet *)tweet{
    return tweet.contentHeight;
}

+ (CGFloat)likeCommentBtn_BottomPadingWithTweet:(Tweet *)tweet{
    if (tweet &&
        (tweet.likes.intValue > 0)){
            return 5.0;
        }else{
            return 0;
        }
}
+ (CGFloat)likeUsersHeightWithTweet:(Tweet *)tweet{
    CGFloat likeUsersHeight = 0;
    if (tweet.likes.intValue > 0) {
        likeUsersHeight = 35;
        //        +30*(ceilf([tweet.like_users count]/kTweet_LikeUsersLineCount)-1);
    }
    return likeUsersHeight;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strLink = request.URL.absoluteString;
    NSLog(@"strLink=[%@]",strLink);
    if ([strLink rangeOfString:@"about:blank"].location != NSNotFound) {
        return YES;
    }else{
        if (_loadRequestBlock) {
            _loadRequestBlock(request);
        }
        return NO;
    }
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [_activityIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self refreshTweetContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _tweet.contentHeight) > 1) {
        NSLog(@"ABS(scrollHeight - _tweet.contentHeight)=========\n scrollHeight: %.2f", ABS(scrollHeight - _tweet.contentHeight));
        webView.scalesPageToFit = YES;
        _tweet.contentHeight = scrollHeight;
        if (_cellHeightChangedBlock) {
            _cellHeightChangedBlock();
        }
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [_activityIndicator stopAnimating];
    if([error code] == NSURLErrorCancelled)
        return;
    else
        DebugLog(@"%@", error.description);
}


- (void)refreshTweetContentView{
    if (_tweetContentView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_tweetContentView.bounds)];
        [_tweetContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark Btn M
- (void)userBtnClicked{
    if (_userBtnClickedBlock) {
        _userBtnClickedBlock(_tweet.owner);
    }
}
- (void)likeBtnClicked:(id)sender{
    DebugLog(@"likeBtnClicked");
    [[Coding_NetAPIManager sharedManager] request_Tweet_DoLike_WithObj:_tweet andBlock:^(id data, NSError *error) {
        if (data) {
            [_tweet changeToLiked:[NSNumber numberWithBool:!_tweet.liked.boolValue]];
            [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_liked_btn":@"tweet_like_btn")] forState:UIControlStateNormal];
            if (_likeBtnClickedBlock) {
                _likeBtnClickedBlock();
            }
        }
    }];
}
- (void)commentBtnClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    if (_commentClickedBlock) {
        _commentClickedBlock(weakSelf);
    }
}
- (void)deleteBtnClicked:(UIButton *)sender{
    if (_deleteClickedBlock) {
        _deleteClickedBlock();
    }
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger row = 0;
    if (_tweet.like_users.count > 0) {
        row = MIN(_tweet.like_users.count, kTweetDetailCell_LikeNumMax);
    }
    return row;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TweetLikeUserCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser forIndexPath:indexPath];
    if (indexPath.row >= kTweetDetailCell_LikeNumMax-1) {
        [ccell configWithUser:nil likesNum:_tweet.likes];
    }else{
        if (_tweet.like_users.count > indexPath.row) {
            User *curUser = [_tweet.like_users objectAtIndex:indexPath.row];
            [ccell configWithUser:curUser likesNum:nil];
        }else {
            [ccell configWithUser:nil likesNum:_tweet.likes];
        }
    }
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize itemSize;
    itemSize = CGSizeMake(kTweetDetailCell_LikeUserCCell_Height, kTweetDetailCell_LikeUserCCell_Height);
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets insetForSection;

        insetForSection = UIEdgeInsetsMake(kTweetDetailCell_LikeUserCCell_Pading, kPaddingLeftWidth, kTweetDetailCell_LikeUserCCell_Pading, kPaddingLeftWidth);
    return insetForSection;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kTweetDetailCell_LikeUserCCell_Pading;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kTweetDetailCell_LikeUserCCell_Pading/2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= 7) {
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


@end
