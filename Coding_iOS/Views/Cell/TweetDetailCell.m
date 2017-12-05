//
//  TweetDetailCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetDetailCell_PadingLeft 60.0
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweetDetailCell_LikeComment_Height 27.0
#define kTweetDetailCell_LikeComment_Width 50.0
#define kTweetDetailCell_ContentWidth (kScreen_Width - 2*kPaddingLeftWidth)
#define kTweetDetailCell_PadingTop 70.0
#define kTweetDetailCell_PadingBottom 10.0
#define kTweetDetailCell_LikeUserCCell_Height 25.0
#define kTweetDetailCell_LikeUserCCell_Pading 5.0

#define kTweetDetailCell_MaxCollectionNum (kDevice_Is_iPhone6Plus? 11: kDevice_Is_iPhone6? 10: 9)



#import "TweetDetailCell.h"
#import "UICustomCollectionView.h"
#import "TweetLikeUserCCell.h"
#import "Coding_NetAPIManager.h"
#import "WebContentManager.h"
#import "CodingShareView.h"
#import "TweetSendLocationDetailViewController.h"
#import "SendRewardManager.h"

@interface TweetDetailCell ()
@property (strong, nonatomic) NSArray *like_reward_users;

@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UIImageView *vipV;
@property (strong, nonatomic) UIButton *ownerNameBtn;
@property (strong, nonatomic) UILabel *timeLabel, *fromLabel;
@property (strong, nonatomic) UIButton *likeBtn, *commentBtn, *deleteBtn, *rewardBtn;
@property (strong, nonatomic) UIButton *locaitonBtn;
@property (strong, nonatomic) UICustomCollectionView *likeUsersView;
@property (strong, nonatomic) UIImageView *timeClockIconView, *fromPhoneIconView;
@property (strong, nonatomic) UIWebView *webContentView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
@implementation TweetDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //        self.backgroundColor = [UIColor colorWithHexString:@"0xf3f3f3"];
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, 45, 45)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
        }
        if (!self.ownerNameBtn) {
            self.ownerNameBtn = [UIButton buttonWithUserStyle];
            self.ownerNameBtn.frame = CGRectMake(CGRectGetMaxX(_ownerImgView.frame) + 15, CGRectGetMinY(self.ownerImgView.frame), kScreen_Width/2, 24);
            [self.ownerNameBtn addTarget:self action:@selector(userBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.ownerNameBtn];
        }
//        if (!self.timeClockIconView) {
//            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 85, 20, 12, 12)];
//            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
//            [self.contentView addSubview:self.timeClockIconView];
//        }
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.ownerNameBtn.frame), CGRectGetMaxY(self.ownerImgView.frame) - 17, kScreen_Width/2, 17)];
//            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 70, 18, 70, 12)];
            self.timeLabel.font = kTweet_TimtFont;
//            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.timeLabel.textColor = kColorDark7;
            [self.contentView addSubview:self.timeLabel];
        }

        if (!self.likeBtn) {
            CGRect frame = CGRectMake(kPaddingLeftWidth, 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            self.likeBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:YES];
            [self.likeBtn addTarget:self action:@selector(likeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.likeBtn];
        }
        if (!self.rewardBtn) {
            CGRect frame = CGRectMake(kPaddingLeftWidth + kTweetDetailCell_LikeComment_Width + 5, 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            self.rewardBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:YES];
            [self.rewardBtn addTarget:self action:@selector(rewardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.rewardBtn];
        }
        if (!self.commentBtn) {
            CGRect frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- kTweetDetailCell_LikeComment_Width, 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            self.commentBtn = [UIButton tweetBtnWithFrame:frame alignmentLeft:NO];
            [self.commentBtn setImage:[UIImage imageNamed:@"tweet_btn_comment"] forState:UIControlStateNormal];
            [self.commentBtn addTarget:self action:@selector(commentBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.commentBtn];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth- 2*kTweetDetailCell_LikeComment_Width- 5 , 0, kTweetDetailCell_LikeComment_Width, kTweetDetailCell_LikeComment_Height);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:self.deleteBtn];
        }
        
        if (!self.locaitonBtn) {
            self.locaitonBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.locaitonBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            self.locaitonBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.locaitonBtn.frame = CGRectMake(kPaddingLeftWidth, 0,
                                                (kScreen_Width - 2*kPaddingLeftWidth), 15);
            self.locaitonBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.locaitonBtn setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
            [self.locaitonBtn addTarget:self action:@selector(locationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.locaitonBtn];
        }
        if (!self.fromPhoneIconView) {
            self.fromPhoneIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, 12, 12)];
            self.fromPhoneIconView.image = [UIImage imageNamed:@"little_phone_icon"];
            [self.contentView addSubview:self.fromPhoneIconView];
        }
        if (!self.fromLabel) {
            self.fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.fromPhoneIconView.frame) + 5, 0, kScreen_Width/2, 15)];
            self.fromLabel.font = kTweet_TimtFont;
            self.fromLabel.textColor = kColorDark7;
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
//            [self.likeUsersView addLineUp:YES andDown:NO andColor:kColorDDD];
            [self.contentView addSubview:self.likeUsersView];
        }
        if (!self.webContentView) {
            self.webContentView = [[UIWebView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kTweetDetailCell_PadingTop, kTweetDetailCell_ContentWidth, 1)];
            self.webContentView.delegate = self;
            self.webContentView.scrollView.scrollEnabled = NO;
            self.webContentView.scrollView.scrollsToTop = NO;
            self.webContentView.scrollView.bounces = NO;
            self.webContentView.backgroundColor = [UIColor clearColor];
            self.webContentView.opaque = NO;
            [self.contentView addSubview:self.webContentView];
        }
        if (!_activityIndicator) {
            _activityIndicator = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:
                                  UIActivityIndicatorViewStyleGray];
            _activityIndicator.hidesWhenStopped = YES;
            [_activityIndicator setCenter:CGPointMake(CGRectGetMidX(self.webContentView.frame), kTweetDetailCell_PadingTop+CGRectGetHeight(_activityIndicator.bounds)/2)];
            [self.contentView addSubview:_activityIndicator];
        }
        if (!_vipV) {
            _vipV = [UIImageView new];
            [self.contentView addSubview:_vipV];
            [_vipV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.bottom.equalTo(_ownerImgView);
            }];
        }
    }
    return self;
}

- (void)setTweet:(Tweet *)tweet{
    _tweet = tweet;
    _like_reward_users = [_tweet like_reward_users];

    if (!_tweet) {
        return;
    }
    
    self.likeBtn.hidden = self.rewardBtn.hidden = [_tweet isProjectTweet];
    
    //owner头像
    __weak __typeof(self)weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    _vipV.image = [UIImage imageNamed:[NSString stringWithFormat:@"vip_%@_45", _tweet.owner.vip]];

    //owner姓名
//    [self.ownerNameBtn setUserTitle:_tweet.owner.name];
    [self.ownerNameBtn setUserTitle:_tweet.owner.name font:self.ownerNameBtn.titleLabel.font maxWidth:(kScreen_Width- kTweetDetailCell_PadingLeft - 85)];

    //发出冒泡的时间
    self.timeLabel.text = [_tweet.created_at stringDisplay_HHmm];
//    [self.timeLabel setLongString:[_tweet.created_at stringDisplay_HHmm] withVariableWidth:kScreen_Width/2];
//    CGFloat timeLabelX = kScreen_Width - kPaddingLeftWidth - CGRectGetWidth(self.timeLabel.frame);
//    [self.timeLabel setX:timeLabelX];
//    [self.timeClockIconView setX:timeLabelX-15];
    
    //owner冒泡text内容
    [self.webContentView setHeight:_tweet.contentHeight];
    if (!_webContentView.isLoading) {
        [_activityIndicator startAnimating];
        if (_tweet.htmlMedia.contentOrigional) {
            [self.webContentView loadHTMLString:[WebContentManager bubblePatternedWithContent:_tweet.htmlMedia.contentOrigional] baseURL:nil];
        }
    }
    
    CGFloat curBottomY = kTweetDetailCell_PadingTop +[[self class] contentHeightWithTweet:_tweet];
    curBottomY += 10;
    
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
    self.likeBtn.y = self.rewardBtn.y = self.commentBtn.y = curBottomY;
    [self.likeBtn setImage:[UIImage imageNamed:(_tweet.liked.boolValue? @"tweet_btn_liked":@"tweet_btn_like")] forState:UIControlStateNormal];
    [self.likeBtn setTitle:_tweet.likes.stringValue forState:UIControlStateNormal];
    [self.rewardBtn setImage:[UIImage imageNamed:(_tweet.rewarded.boolValue? @"tweet_btn_rewarded": @"tweet_btn_reward")] forState:UIControlStateNormal];
    [self.rewardBtn setTitle:_tweet.rewards.stringValue forState:UIControlStateNormal];
    [self.commentBtn setTitle:_tweet.comments.stringValue forState:UIControlStateNormal];

    BOOL isMineTweet = [_tweet.owner.global_key isEqualToString:[Login curLoginUser].global_key];
    if (isMineTweet) {
        [self.deleteBtn setY:curBottomY];
        self.deleteBtn.hidden = NO;
    }else{
        self.deleteBtn.hidden = YES;
    }

    
    curBottomY += kTweetDetailCell_LikeComment_Height;
    curBottomY += [[self class] likeCommentBtn_BottomPadingWithTweet:_tweet];
    
    
    //点赞的人_列表
    //    可有可无
    if ([_tweet hasLikesOrRewards]) {
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
        cellHeight += 5 + kTweetDetailCell_LikeComment_Height;
        cellHeight += [[self class] locationAndDeviceHeightWithTweet:tweet];
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
        ([tweet hasLikesOrRewards])){
            return 5.0;
        }else{
            return 0;
        }
}
+ (CGFloat)likeUsersHeightWithTweet:(Tweet *)tweet{
    CGFloat likeUsersHeight = 0;
    if ([tweet hasLikesOrRewards]) {
        likeUsersHeight = [TweetLikeUserCCell ccellSize].height + 15 + 5;
        //        +30*(ceilf([tweet.like_users count]/kTweet_LikeUsersLineCount)-1);
    }
    return likeUsersHeight;
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

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *strLink = request.URL.absoluteString;
    DebugLog(@"strLink=[%@]",strLink);
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
    [self refreshwebContentView];
    [_activityIndicator stopAnimating];
    CGFloat scrollHeight = webView.scrollView.contentSize.height;
    if (ABS(scrollHeight - _tweet.contentHeight) > 5) {
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


- (void)refreshwebContentView{
    if (_webContentView) {
        //修改服务器页面的meta的值
        NSString *meta = [NSString stringWithFormat:@"document.getElementsByName(\"viewport\")[0].content = \"width=%f, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\"", CGRectGetWidth(_webContentView.frame)];
        [_webContentView stringByEvaluatingJavaScriptFromString:meta];
    }
}

#pragma mark Btn M
- (void)userBtnClicked{
    if (_userBtnClickedBlock) {
        _userBtnClickedBlock(_tweet.owner);
    }
}
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

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger row = MIN(kTweetDetailCell_MaxCollectionNum, [_tweet hasMoreLikesOrRewards]? _like_reward_users.count + 1: _like_reward_users.count);
    return row;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TweetLikeUserCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser forIndexPath:indexPath];
    if (indexPath.row >= kTweetDetailCell_MaxCollectionNum -1
        || indexPath.row >= _like_reward_users.count) {
        [ccell configWithUser:nil rewarded:NO];
    }else{
        User *curUser = [_like_reward_users objectAtIndex:indexPath.row];
        [ccell configWithUser:curUser rewarded:[_tweet rewardedBy:curUser]];
    }
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize itemSize = [TweetLikeUserCCell ccellSize];
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets insetForSection;
    insetForSection = UIEdgeInsetsMake(15, kPaddingLeftWidth, 5, kPaddingLeftWidth);
    return insetForSection;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kTweetDetailCell_LikeUserCCell_Pading;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kTweetDetailCell_LikeUserCCell_Pading/2;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= kTweetDetailCell_MaxCollectionNum -1
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


@end
