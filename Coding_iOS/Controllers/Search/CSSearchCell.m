//
//  CSSearchCell.m
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/23.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CSSearchCell.h"
#import "UICustomCollectionView.h"
#import "TweetMediaItemCCell.h"
#import "TweetMediaItemSingleCCell.h"
#import "TweetLikeUserCCell.h"
#import "MJPhotoBrowser.h"

#define kTweetCell_PadingLeft 52.0
#define kTweetCell_PadingTop 10.0
#define kTweetCell_PadingBottom 10.0
#define kTweetCell_ContentWidth (kScreen_Width - kTweetCell_PadingLeft - kPaddingLeftWidth)
#define kTweet_ContentMaxHeight 50.0
#define kTweet_ContentFont [UIFont systemFontOfSize:15]
#define kTweetCell_LikeUserCCell_Height 25.0
#define kTweetCell_LikeUserCCell_Pading 10.0
#define kTweet_TimtFont [UIFont systemFontOfSize:12]
#define kTweetCell_NameMaxWidth (kTweetCell_ContentWidth - )

@interface CSSearchCell ()

@property (strong, nonatomic) UITapImageView *ownerImgView;
@property (strong, nonatomic) UILabel *timeLabel, *nameLabel, *likeLabel, *commentLabel;
@property (strong, nonatomic) UIImageView *timeClockIconView, *tweetCommentIconView, *tweetLikeIconView, *detailIconView;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
//@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;

@end

@implementation CSSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    
        if (!self.ownerImgView) {
            self.ownerImgView = [[UITapImageView alloc] initWithFrame:CGRectMake(12, 10, 30, 30)];
            [self.ownerImgView doCircleFrame];
            [self.contentView addSubview:self.ownerImgView];
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
        
//        if (!self.mediaView) {
//            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
//            self.mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, kTweetCell_ContentWidth, 80) collectionViewLayout:layout];
//            self.mediaView.scrollEnabled = NO;
//            [self.mediaView setBackgroundView:nil];
//            [self.mediaView setBackgroundColor:[UIColor clearColor]];
//            [self.mediaView registerClass:[TweetMediaItemCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItem];
//            [self.mediaView registerClass:[TweetMediaItemSingleCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItemSingle];
//            self.mediaView.dataSource = self;
//            self.mediaView.delegate = self;
//            [self.contentView addSubview:self.mediaView];
//        }
        
        if(!self.nameLabel) {
            self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 0, 12)];
            self.nameLabel.font = kTweet_TimtFont;
            self.nameLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.nameLabel];
        }
        
        if (!self.timeClockIconView) {
            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 12, 12)];
            self.timeClockIconView.image = [UIImage imageNamed:@"search_tweet_clock"];
            [self.contentView addSubview:self.timeClockIconView];
        }
        
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 55, 12)];
            self.timeLabel.font = kTweet_TimtFont;
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
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
            self.likeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.likeLabel];
        }
        
        if(!self.tweetCommentIconView) {
            self.tweetCommentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 12, 12)];
            self.tweetCommentIconView.image = [UIImage imageNamed:@"search_tweet_comment"];
            [self.contentView addSubview:self.tweetCommentIconView];
        }
        
        if (!self.commentLabel) {
            self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTweetCell_PadingLeft, 0, 55, 12)];
            self.commentLabel.font = kTweet_TimtFont;
            self.commentLabel.textAlignment = NSTextAlignmentLeft;
            self.commentLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:self.commentLabel];
        }
        
        if(!self.detailIconView) {
            self.detailIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width - kPaddingLeftWidth - 8, 0, 20, 20)];
            self.detailIconView.image = [UIImage imageNamed:@"me_info_arrow_left"];
            [self.contentView addSubview:self.detailIconView];
        }
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {

    [super layoutSubviews];
    
    __weak __typeof(self) weakSelf = self;
    [self.ownerImgView setImageWithUrl:[_tweet.owner.avatar urlImageWithCodePathResizeToView:_ownerImgView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerImgView) tapBlock:^(id obj) {
        [weakSelf userBtnClicked];
    }];
    
    if(_tweet.content.length > 0) {
    
        [self.contentLabel setLongString:_tweet.content withFitWidth:kTweetCell_ContentWidth maxHeight:kTweet_ContentMaxHeight];
    }else {
        
        [self.contentLabel setLongString:@"[图片]" withFitWidth:kTweetCell_ContentWidth maxHeight:kTweet_ContentMaxHeight];
        
    }
    
    for (HtmlMediaItem *item in _tweet.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    CGFloat curBottomY = kTweetCell_PadingTop + [CSSearchCell contentLabelHeightWithTweet:_tweet] + 10;
    //图片缩略图展示
//    if (_tweet.htmlMedia.imageItems.count > 0) {
//        
//        CGFloat mediaHeight = [CSSearchCell contentMediaHeightWithTweet:_tweet];
//        [self.mediaView setFrame:CGRectMake(kTweetCell_PadingLeft, curBottomY, kTweetCell_ContentWidth, mediaHeight)];
//        [self.mediaView reloadData];
//        self.mediaView.hidden = NO;
//        
//        curBottomY += mediaHeight + 10;
//    }else{
//        if (self.mediaView) {
//            self.mediaView.hidden = YES;
//        }
//    }
    
    CGFloat curX = kTweetCell_PadingLeft;
    [self.nameLabel setLongString:_tweet.owner.name withVariableWidth:kScreen_Width / 2];
    [self.nameLabel setY:curBottomY];
    
    curX += self.nameLabel.frame.size.width + 7;
    [self.timeClockIconView setX:curX];
    [self.timeClockIconView setY:curBottomY + 2];
    
    curX += self.timeClockIconView.frame.size.width + 3;
    [self.timeLabel setLongString:[_tweet.created_at stringTimesAgo] withVariableWidth:kScreen_Width / 6];
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
    
    [self.detailIconView setY:([CSSearchCell cellHeightWithObj:_tweet] - 12) / 2]; 
}

+ (CGFloat)cellHeightWithObj:(id)obj {

    Tweet *tweet = (Tweet *)obj;
    CGFloat cellHeight = 0;
    if (tweet.likes.integerValue > 0 || tweet.comments.integerValue > 0) {
        cellHeight = 6;
    }else{
        cellHeight = 3;
    }
    cellHeight += 20;
    cellHeight += kTweetCell_PadingTop;
    cellHeight += [CSSearchCell contentLabelHeightWithTweet:tweet];
    cellHeight += kTweetCell_PadingBottom;
    return cellHeight;
}

+ (CGFloat)contentLabelHeightWithTweet:(Tweet *)tweet {
    
    return MIN(kTweet_ContentMaxHeight, [(tweet.content.length > 0 ? tweet.content : @"[图片]") getHeightWithFont:kTweet_ContentFont constrainedToSize:CGSizeMake(kTweetCell_ContentWidth, CGFLOAT_MAX)]);
}

+ (CGFloat)contentMediaHeightWithTweet:(Tweet *)tweet {
    
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

- (void)userBtnClicked {
    
    if (_userBtnClickedBlock) {
        _userBtnClickedBlock(_tweet.owner);
    }
}

#pragma -
#pragma mark Collection M
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    
//    NSInteger row = 0;
//    if (collectionView == _mediaView) {
//        row = _tweet.htmlMedia.imageItems.count;
//    }else{
//        row = _tweet.numOfLikers;
//    }
//    return row;
//}
//
//// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (collectionView == _mediaView) {
//        HtmlMediaItem *curMediaItem = [_tweet.htmlMedia.imageItems objectAtIndex:indexPath.row];
//        if (_tweet.htmlMedia.imageItems.count == 1) {
//            TweetMediaItemSingleCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItemSingle forIndexPath:indexPath];
//            ccell.curMediaItem = curMediaItem;
//            ccell.refreshSingleCCellBlock = ^(){
////                if (_refreshSingleCCellBlock) {
////                    _refreshSingleCCellBlock();
////                }
//            };
//            [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
//            return ccell;
//        }else{
//            TweetMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetMediaItem forIndexPath:indexPath];
//            ccell.curMediaItem = curMediaItem;
//            [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
//            return ccell;
//        }
//    }else{
//        TweetLikeUserCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TweetLikeUser forIndexPath:indexPath];
//        if (indexPath.row >= _tweet.numOfLikers-1 && _tweet.hasMoreLikers) {
//            [ccell configWithUser:nil likesNum:_tweet.likes];
//        }else{
//            User *curUser = [_tweet.like_users objectAtIndex:indexPath.row];
//            [ccell configWithUser:curUser likesNum:nil];
//        }
//        return ccell;
//    }
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    CGSize itemSize;
//    if (collectionView == _mediaView) {
//        if (_tweet.htmlMedia.imageItems.count == 1) {
//            itemSize = [TweetMediaItemSingleCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
//        }else{
//            itemSize = [TweetMediaItemCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
//        }
//    }else{
//        itemSize = CGSizeMake(kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height);
//    }
//    return itemSize;
//}
//
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//    UIEdgeInsets insetForSection;
//    if (collectionView == _mediaView) {
//        if (_tweet.htmlMedia.imageItems.count == 1) {
//            CGSize itemSize = [TweetMediaItemSingleCCell ccellSizeWithObj:_tweet.htmlMedia.imageItems.firstObject];
//            insetForSection = UIEdgeInsetsMake(0, 0, 0, kTweetCell_ContentWidth - itemSize.width);
//        }else{
//            insetForSection = UIEdgeInsetsMake(0, 0, 0, 0);
//        }
//    }else{
//        insetForSection = UIEdgeInsetsMake(kTweetCell_LikeUserCCell_Pading, 5, kTweetCell_LikeUserCCell_Pading, 5);
//    }
//    return insetForSection;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return kTweetCell_LikeUserCCell_Pading;
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return kTweetCell_LikeUserCCell_Pading/2;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (collectionView == _mediaView) {
//        //        显示大图
//        int count = (int)_tweet.htmlMedia.imageItems.count;
//        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
//        for (int i = 0; i<count; i++) {
//            HtmlMediaItem *imageItem = [_tweet.htmlMedia.imageItems objectAtIndex:i];
//            MJPhoto *photo = [[MJPhoto alloc] init];
//            photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
//            photo.srcImageView = [_imageViewsDict objectForKey:[NSIndexPath indexPathForItem:i inSection:0]]; // 来源于哪个UIImageView
//            [photos addObject:photo];
//        }
//        
//        // 2.显示相册
//        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
//        browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
//        browser.photos = photos; // 设置所有的图片
//        [browser show];
//    }else{
//        if (indexPath.row >= _tweet.numOfLikers-1 && _tweet.hasMoreLikers) {
////            if (_moreLikersBtnClickedBlock) {
////                _moreLikersBtnClickedBlock(_tweet);
////            }
//        }else{
////            User *curUser = [_tweet.like_users objectAtIndex:indexPath.row];
////            if (_userBtnClickedBlock) {
////                _userBtnClickedBlock(curUser);
////            }
//        }
//    }
//}

#pragma -
#pragma mark TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTransitInformation:(NSDictionary *)components{
    
    if (_mediaItemClickedBlock) {
        _mediaItemClickedBlock([components objectForKey:@"value"]);
    }
}


@end
