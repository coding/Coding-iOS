//
//  MessageCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Message @"MessageCell"
#define kCellIdentifier_MessageMedia @"MessageMediaCell"
#define kCCellIdentifier_MessageMediaItem @"MessageMediaItemCCell"

#define kMessageCell_FontContent [UIFont systemFontOfSize:15]
#define kMessageCell_PadingWidth 20.0
#define kMessageCell_PadingHeight 11.0
#define kMessageCell_ContentWidth (kScreen_Width*0.6)
#define kMessageCell_TimeHeight 40.0
#define kMessageCell_UserIconWith 40.0


#import "MessageCell.h"
#import "UITapImageView.h"
#import "MessageMediaItemCCell.h"
#import "MJPhotoBrowser.h"
#import "UICustomCollectionView.h"
#import "Login.h"


@interface MessageCell ()
@property (strong, nonatomic) PrivateMessage *curPriMsg, *prePriMsg;

@property (strong, nonatomic) UITapImageView *userIconView;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;

@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;
@property (strong, nonatomic) UITapImageView *failStatus;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];

        if (!_userIconView) {
            _userIconView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_UserIconWith, kMessageCell_UserIconWith)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        
        if (!_bgImgView) {
            _bgImgView = [[UILongPressMenuImageView alloc] initWithFrame:CGRectZero];
            _bgImgView.userInteractionEnabled = YES;
            [self.contentView addSubview:_bgImgView];
        }
        
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kMessageCell_PadingWidth, kMessageCell_PadingHeight, 0, 0)];
            _contentLabel.numberOfLines = 0;
            _contentLabel.font =kMessageCell_FontContent;
            _contentLabel.backgroundColor = [UIColor clearColor];
            [_bgImgView addSubview:_contentLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_MessageMedia]) {
            if (!self.mediaView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.mediaView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kMessageCell_PadingWidth, kMessageCell_PadingHeight, kMessageCell_ContentWidth, 80) collectionViewLayout:layout];
                self.mediaView.scrollEnabled = NO;
                [self.mediaView setBackgroundView:nil];
                [self.mediaView setBackgroundColor:[UIColor clearColor]];
                [self.mediaView registerClass:[MessageMediaItemCCell class] forCellWithReuseIdentifier:kCCellIdentifier_MessageMediaItem];
                self.mediaView.dataSource = self;
                self.mediaView.delegate = self;
                [_bgImgView addSubview:self.mediaView];
            }
            if (!_imageViewsDict) {
                _imageViewsDict = [[NSMutableDictionary alloc] init];
            }
        }
    }
    return self;
}

- (void)setCurPriMsg:(PrivateMessage *)curPriMsg andPrePriMsg:(PrivateMessage *)prePriMsg{
    if (_curPriMsg == curPriMsg && _prePriMsg == prePriMsg) {
        [self configSendStatus];
        return;
    }else{
        _curPriMsg = curPriMsg;
        _prePriMsg = prePriMsg;
    }

    
    if (!_curPriMsg) {
        return;
    }
    CGFloat curBottomY = 0;
    NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:_curPriMsg preMsg:_prePriMsg];
    if (displayStr) {
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kMessageCell_TimeHeight- 20)/2, kScreen_Width-2*kPaddingLeftWidth, 20)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_timeLabel];
        }
        _timeLabel.hidden = NO;
        _timeLabel.text = displayStr;
        curBottomY += kMessageCell_TimeHeight;
    }else{
        _timeLabel.hidden = YES;
    }
    
    UIImage *bgImg;
    CGSize bgImgViewSize;
    CGSize textSize;
    CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:_curPriMsg];
    
    if (_curPriMsg.content.length > 0) {
        textSize = [_curPriMsg.content getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
    }else{
        textSize = CGSizeZero;
    }
    
    [_contentLabel setWidth:kMessageCell_ContentWidth];
    _contentLabel.text = _curPriMsg.content;
    [_contentLabel sizeToFit];
    textSize.height = CGRectGetHeight(_contentLabel.frame);
    
    
    if (mediaViewHeight > 0) {
        //        有图片
        [_contentLabel setY:2*kMessageCell_PadingHeight + mediaViewHeight];
        
        bgImgViewSize = CGSizeMake(kMessageCell_ContentWidth +2*kMessageCell_PadingWidth,
                                   mediaViewHeight +textSize.height + kMessageCell_PadingHeight*(_curPriMsg.content.length > 0? 3:2));
    }else{
        [_contentLabel setY:kMessageCell_PadingHeight];
        
        bgImgViewSize = CGSizeMake(textSize.width +2*kMessageCell_PadingWidth, textSize.height +2*kMessageCell_PadingHeight);
    }
    
    CGRect bgImgViewFrame;
    if (![_curPriMsg.sender.global_key isEqualToString:[Login curLoginUser].global_key]) {
        //        这是好友发的
        bgImgViewFrame = CGRectMake(kPaddingLeftWidth +kMessageCell_UserIconWith, curBottomY +10, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kPaddingLeftWidth +kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        bgImg = [[UIImage imageNamed:@"messageLeft_bg_img"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 15, 25)];
        _contentLabel.textColor = [UIColor blackColor];
        _bgImgView.frame = bgImgViewFrame;
    }else{
        //        这是自己发的
        bgImgViewFrame = CGRectMake((kScreen_Width - kPaddingLeftWidth - kMessageCell_UserIconWith) -bgImgViewSize.width, curBottomY +10, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kScreen_Width - kPaddingLeftWidth -kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        bgImg = [[UIImage imageNamed:@"messageRight_bg_img"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 25, 15, 25)];
        _contentLabel.textColor = [UIColor blackColor];
        _bgImgView.frame = bgImgViewFrame;
    }
    
    __weak typeof(self) weakSelf = self;
    [_userIconView addTapBlock:^(id obj) {
        weakSelf.tapUserIconBlock(weakSelf.curPriMsg.sender);
    }];
    [_userIconView sd_setImageWithURL:[_curPriMsg.sender.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    
    [_bgImgView setImage:bgImg];
    
    if (_mediaView) {
        [_mediaView setHeight:mediaViewHeight];
        [_mediaView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
    [self configSendStatus];

}

- (void)configSendStatus{
    CGPoint statusCenter = CGPointMake(CGRectGetMinX(_bgImgView.frame) -20, CGRectGetMinY(_bgImgView.frame)+ 15);
    if (_curPriMsg.sendStatus == PrivateMessageStatusSendSucess) {
        if (_sendingStatus) {
            [_sendingStatus stopAnimating];
        }
        if (_failStatus) {
            _failStatus.hidden = YES;
        }
    }else if (_curPriMsg.sendStatus == PrivateMessageStatusSending){
        if (!_sendingStatus) {
            _sendingStatus = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _sendingStatus.hidesWhenStopped = YES;
            [self.contentView addSubview:_sendingStatus];
        }
        [_sendingStatus setCenter:statusCenter];
        [_sendingStatus startAnimating];
        if (_failStatus) {
            _failStatus.hidden = YES;
        }
    }else if (_curPriMsg.sendStatus == PrivateMessageStatusSendFail){
        if (_sendingStatus) {
            [_sendingStatus stopAnimating];
        }
        __weak typeof(self) weakSelf = self;
        if (!_failStatus) {
            _failStatus = [[UITapImageView alloc] initWithImage:[UIImage imageNamed:@"private_message_send_fail"]];
            if (weakSelf.resendMessageBlock) {
                [weakSelf.failStatus addTapBlock:^(id obj) {
                    weakSelf.resendMessageBlock(weakSelf.curPriMsg);
                }];
            }
            [self.contentView addSubview:_failStatus];
        }
        [_failStatus setCenter:statusCenter];
        _failStatus.hidden = NO;
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj preObj:(id)preObj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[PrivateMessage class]]) {
        PrivateMessage *curPriMsg = (PrivateMessage *)obj;
        CGSize textSize = [curPriMsg.content getSizeWithFont:kMessageCell_FontContent constrainedToSize:CGSizeMake(kMessageCell_ContentWidth, CGFLOAT_MAX)];
        if ([curPriMsg.content containsEmoji]) {
            textSize.height += 10;
        }
        CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
        cellHeight += mediaViewHeight;
        cellHeight += textSize.height + kMessageCell_PadingHeight*5;
        
        if (mediaViewHeight > 0 && curPriMsg.content && curPriMsg.content.length > 0) {
            cellHeight += kMessageCell_PadingHeight;
        }
        
        PrivateMessage *prePriMsg = (PrivateMessage *)preObj;
        NSString *displayStr = [MessageCell displayTimeStrWithCurMsg:curPriMsg preMsg:prePriMsg];
        if (displayStr) {
            cellHeight += kMessageCell_TimeHeight;
        }
    }
    return cellHeight;
}

+ (NSString *)displayTimeStrWithCurMsg:(PrivateMessage *)cur preMsg:(PrivateMessage *)pre{
    NSString *displayStr = nil;
    if (!pre || [cur.created_at timeIntervalSinceDate:pre.created_at] > 1*60) {
        displayStr = [cur.created_at stringTimeDisplay];
    }
    return displayStr;
}

+ (CGFloat)mediaViewHeightWithObj:(PrivateMessage *)curPriMsg{
    CGFloat mediaViewHeight = 0;
    if (curPriMsg.nextImg) {
        mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curPriMsg.nextImg].height;
    }else{
        for (HtmlMediaItem *curItem in curPriMsg.htmlMedia.imageItems) {
            mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curItem].height +10;
        }
        mediaViewHeight -= 10;
    }
    return mediaViewHeight;
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!_curPriMsg) {
        return 0;
    }
    NSUInteger mediaCount = (_curPriMsg.htmlMedia && _curPriMsg.htmlMedia.imageItems.count> 0)? _curPriMsg.htmlMedia.imageItems.count : 1;
    return mediaCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MessageMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_MessageMediaItem forIndexPath:indexPath];
    ccell.refreshMessageMediaCCellBlock = self.refreshMessageMediaCCellBlock;

    ccell.curPriMsg = _curPriMsg;
    if (_curPriMsg.nextImg) {
        ccell.curObj = _curPriMsg.nextImg;
    }else{
        HtmlMediaItem *curItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
        ccell.curObj = curItem;
    }
    [_imageViewsDict setObject:ccell.imgView forKey:indexPath];
    return ccell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize itemSize = CGSizeZero;
    if (_curPriMsg.nextImg) {
        itemSize = [MessageMediaItemCCell ccellSizeWithObj:_curPriMsg.nextImg];
    }else{
        HtmlMediaItem *curItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
        itemSize = [MessageMediaItemCCell ccellSizeWithObj:curItem];
    }
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger mediaCount = (_curPriMsg.htmlMedia && _curPriMsg.htmlMedia.imageItems.count> 0)? _curPriMsg.htmlMedia.imageItems.count : 1;

    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:mediaCount];
    if (_curPriMsg.nextImg) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.srcImageView = [_imageViewsDict objectForKey:indexPath]; // 来源于哪个UIImageView
        photo.image = _curPriMsg.nextImg; // 图片
        [photos addObject:photo];
    }else{
        for (int i = 0; i<mediaCount; i++) {
            HtmlMediaItem *imageItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.srcImageView = [_imageViewsDict objectForKey:indexPath]; // 来源于哪个UIImageView
            photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
            [photos addObject:photo];
        }
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}
@end
