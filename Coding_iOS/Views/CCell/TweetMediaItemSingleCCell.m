//
//  TweetMediaItemSingleCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetMediaItemCCellSingle_Width (0.6 *kScreen_Width)
#define kTweetMediaItemCCellSingle_WidthMonkey ((kScreen_Width - 36.0)/3.0)
#define kTweetMediaItemCCellSingle_MaxHeight (0.5 *kScreen_Height)

#import "TweetMediaItemSingleCCell.h"
#import "UIImageView+WebCache.h"


@implementation TweetMediaItemSingleCCell
@synthesize curMediaItem = _curMediaItem, imgView = _imgView, gifMarkView = _gifMarkView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setCurMediaItem:(HtmlMediaItem *)curMediaItem{
    if (!_imgView) {
        _imgView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetMediaItemCCellSingle_Width, kTweetMediaItemCCellSingle_Width)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
//        _imgView.layer.masksToBounds = YES;
//        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
    }
    
    if (_curMediaItem != curMediaItem) {
        _curMediaItem = curMediaItem;
    }
    __weak typeof(self) weakSelf = self;
    CGSize reSize;
    if (curMediaItem.type == HtmlMediaItemType_EmotionMonkey) {
        reSize = CGSizeMake(kTweetMediaItemCCellSingle_WidthMonkey, kTweetMediaItemCCellSingle_WidthMonkey);
    }else{
        reSize = [[ImageSizeManager shareManager] sizeWithSrc:_curMediaItem.src originalWidth:kTweetMediaItemCCellSingle_Width maxHeight:kTweetMediaItemCCellSingle_MaxHeight];
    }
    [_imgView sd_setImageWithURL:[_curMediaItem.src urlImageWithCodePathResize:2*reSize.width] placeholderImage:kPlaceholderCodingSquareWidth(150.0) options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            if (![[ImageSizeManager shareManager] hasSrc:weakSelf.curMediaItem.src]) {
                [[ImageSizeManager shareManager] saveImage:weakSelf.curMediaItem.src size:image.size];
                if (weakSelf.refreshSingleCCellBlock) {
                    weakSelf.refreshSingleCCellBlock();
                }
            }
        }
    }];
    [_imgView setSize:reSize];
    
    //        gifMark
    if ([self.curMediaItem isGif]) {
        if (!_gifMarkView) {
            _gifMarkView = ({
                UIImageView *imgView = [UIImageView new];
                imgView.image = [UIImage imageNamed:@"gif_mark"];
                [self.imgView addSubview:imgView];
                @weakify(self);
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    @strongify(self);
                    make.size.mas_equalTo(CGSizeMake(24, 13));
                    make.right.bottom.equalTo(self.imgView).offset(0);
                }];
                imgView;
            });
        }
        self.gifMarkView.hidden = NO;
    }else{
        self.gifMarkView.hidden = YES;
    }
}

+(CGSize)ccellSizeWithObj:(id)obj{
    CGSize itemSize;
    if ([obj isKindOfClass:[HtmlMediaItem class]]) {
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        if (curMediaItem.type == HtmlMediaItemType_EmotionMonkey) {
            itemSize = CGSizeMake(kTweetMediaItemCCellSingle_WidthMonkey, kTweetMediaItemCCellSingle_WidthMonkey);
        }else{
            itemSize = [[ImageSizeManager shareManager] sizeWithSrc:curMediaItem.src originalWidth:kTweetMediaItemCCellSingle_Width maxHeight:kTweetMediaItemCCellSingle_MaxHeight];
        }

    }
    return itemSize;
}

@end
