//
//  MessageCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

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
#import "BubblePlayView.h"
#import "Coding_NetAPIManager.h"

@interface MessageCell ()
@property (strong, nonatomic) PrivateMessage *curPriMsg, *prePriMsg;

@property (strong, nonatomic) UITapImageView *userIconView;
@property (strong, nonatomic) UICustomCollectionView *mediaView;
@property (strong, nonatomic) BubblePlayView *voiceView;
@property (strong, nonatomic) NSMutableDictionary *imageViewsDict;

@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;
@property (strong, nonatomic) UITapImageView *failStatus;
@property (strong, nonatomic) UILabel *timeLabel;

@property (nonatomic, assign) CGFloat preMediaViewHeight;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _preMediaViewHeight = 0;

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
            _contentLabel.textColor = [UIColor blackColor];
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
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
                [self.mediaView registerClass:[MessageMediaItemCCell class] forCellWithReuseIdentifier:kCCellIdentifier_MessageMediaItem_Single];
                self.mediaView.dataSource = self;
                self.mediaView.delegate = self;
                [_bgImgView addSubview:self.mediaView];
            }
            if (!_imageViewsDict) {
                _imageViewsDict = [[NSMutableDictionary alloc] init];
            }
        }
        else if ([reuseIdentifier isEqualToString:kCellIdentifier_MessageVoice]) {
            if (!_voiceView) {
                _voiceView = [[BubblePlayView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_ContentWidth, 40)];
                [_bgImgView addSubview:_voiceView];
            }
        }
    }
    return self;
}

- (void)setCurPriMsg:(PrivateMessage *)curPriMsg andPrePriMsg:(PrivateMessage *)prePriMsg{
    CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
    BOOL isMyMsg = [curPriMsg.sender.global_key isEqualToString:[Login curLoginUser].global_key];

    if (_curPriMsg == curPriMsg && _prePriMsg == prePriMsg && _preMediaViewHeight == mediaViewHeight) {
        [self configSendStatus];
        //refresh voice view play state
        if (_voiceView) {
            if (curPriMsg.file) {
                [_voiceView setUrl:[NSURL URLWithString:curPriMsg.file]];
            }
            else {
                [_voiceView setUrl:[NSURL fileURLWithPath:curPriMsg.voiceMedia.file]];
            }
            _voiceView.isUnread = !isMyMsg && (curPriMsg.played.intValue == 0);
        }
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
            _timeLabel.textColor = kColor999;
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
    
    [_contentLabel setWidth:kMessageCell_ContentWidth];
    _contentLabel.text = _curPriMsg.content;
    [_contentLabel sizeToFit];
    
    textSize = _curPriMsg.content.length > 0? _contentLabel.size: CGSizeZero;

    for (HtmlMediaItem *item in _curPriMsg.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && item.href.length > 0) {
            [self.contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    if (mediaViewHeight > 0) {
        //        有图片
        [_contentLabel setY:2*kMessageCell_PadingHeight + mediaViewHeight];
        
        CGFloat contentWidth = [_curPriMsg isSingleBigMonkey]? [MessageMediaItemCCell monkeyCcellSize].width : kMessageCell_ContentWidth;
        bgImgViewSize = CGSizeMake(contentWidth +2*kMessageCell_PadingWidth,
                                   mediaViewHeight +textSize.height + kMessageCell_PadingHeight*(_curPriMsg.content.length > 0? 3:2));
    } else if ([curPriMsg isVoice]) {
        bgImgViewSize = CGSizeMake(kMessageCell_ContentWidth, 40);
    } else{
        [_contentLabel setY:kMessageCell_PadingHeight];
        
        bgImgViewSize = CGSizeMake(textSize.width +2*kMessageCell_PadingWidth, textSize.height +2*kMessageCell_PadingHeight);
    }
    
    if (_voiceView) {
        if (curPriMsg.file) {
            [_voiceView setUrl:[NSURL URLWithString:curPriMsg.file]];
            _voiceView.duration = curPriMsg.duration.doubleValue/1000;
        }
        else {
            [_voiceView setUrl:[NSURL fileURLWithPath:curPriMsg.voiceMedia.file]];
            _voiceView.duration = curPriMsg.voiceMedia.duration;
        }
        _voiceView.isUnread = !isMyMsg && (curPriMsg.played.intValue == 0);
        
        _voiceView.playStartedBlock = ^(AudioPlayView *view) {
            BubblePlayView *bubbleView = (BubblePlayView *)view;
            if (bubbleView.isUnread) {
                [[Coding_NetAPIManager sharedManager] request_playedPrivateMessage:curPriMsg];
                bubbleView.isUnread = NO;
                curPriMsg.played = @1;
            }
        };
        bgImgViewSize = CGSizeMake(_voiceView.frame.size.width, 40);
        _voiceView.type = isMyMsg? BubbleTypeRight: BubbleTypeLeft;
    }
    
    CGRect bgImgViewFrame;
    if (!isMyMsg) {
        //        这是好友发的
        bgImgViewFrame = CGRectMake(kPaddingLeftWidth +kMessageCell_UserIconWith, curBottomY +kMessageCell_PadingHeight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kPaddingLeftWidth +kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        _bgImgView.frame = bgImgViewFrame;
    }else{
        //        这是自己发的
        bgImgViewFrame = CGRectMake((kScreen_Width - kPaddingLeftWidth - kMessageCell_UserIconWith) -bgImgViewSize.width, curBottomY +kMessageCell_PadingHeight, bgImgViewSize.width, bgImgViewSize.height);
        [_userIconView setCenter:CGPointMake(kScreen_Width - kPaddingLeftWidth -kMessageCell_UserIconWith/2, CGRectGetMaxY(bgImgViewFrame)- kMessageCell_UserIconWith/2)];
        _bgImgView.frame = bgImgViewFrame;
    }
    if (_voiceView || [_curPriMsg isSingleBigMonkey] ) {
        bgImg = nil;
    }else{
        bgImg = [UIImage imageNamed:isMyMsg? @"messageRight_bg_img": @"messageLeft_bg_img"];
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImg.size.height - 19, bgImg.size.width - 31)];
    }
    
    __weak typeof(self) weakSelf = self;
    [_userIconView addTapBlock:^(id obj) {
        weakSelf.tapUserIconBlock(weakSelf.curPriMsg.sender);
    }];
    [_userIconView sd_setImageWithURL:[_curPriMsg.sender.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    
    [_bgImgView setImage:bgImg];
    
    if (_mediaView) {
        CGFloat contentWidth = [_curPriMsg isSingleBigMonkey]? [MessageMediaItemCCell monkeyCcellSize].width : kMessageCell_ContentWidth;
        [_mediaView setSize:CGSizeMake(contentWidth, mediaViewHeight)];
        [_mediaView reloadData];
    }
    
    [self configSendStatus];
    
    _preMediaViewHeight = mediaViewHeight;
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
        CGFloat mediaViewHeight = [MessageCell mediaViewHeightWithObj:curPriMsg];
        cellHeight += mediaViewHeight;
        if ([curPriMsg isVoice]) {
            cellHeight += kMessageCell_PadingHeight*2+40;
        } else {
            cellHeight += textSize.height + kMessageCell_PadingHeight*4;
        }
        
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
        displayStr = [cur.created_at stringDisplay_HHmm];
    }
    return displayStr;
}

+ (CGFloat)mediaViewHeightWithObj:(PrivateMessage *)curPriMsg{
    CGFloat mediaViewHeight = 0;
    if (curPriMsg.hasMedia) {
        if (curPriMsg.nextImg) {
            mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curPriMsg.nextImg].height;
        }else{
            if ([curPriMsg isSingleBigMonkey]) {
                mediaViewHeight += [MessageMediaItemCCell monkeyCcellSize].height;
            }else{
                for (HtmlMediaItem *curItem in curPriMsg.htmlMedia.imageItems) {
                    mediaViewHeight += [MessageMediaItemCCell ccellSizeWithObj:curItem].height +kMessageCell_PadingHeight;
                }
                mediaViewHeight -= kMessageCell_PadingHeight;
            }
        }
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
    MessageMediaItemCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:[_curPriMsg isSingleBigMonkey]? kCCellIdentifier_MessageMediaItem_Single: kCCellIdentifier_MessageMediaItem forIndexPath:indexPath];
    ccell.refreshMessageMediaCCellBlock = self.refreshMessageMediaCCellBlock;
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
        if ([_curPriMsg isSingleBigMonkey]) {
            itemSize = [MessageMediaItemCCell monkeyCcellSize];
        }else{
            HtmlMediaItem *curItem = [_curPriMsg.htmlMedia.imageItems objectAtIndex:indexPath.row];
            itemSize = [MessageMediaItemCCell ccellSizeWithObj:curItem];
        }
    }
    return itemSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kMessageCell_PadingHeight;
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
