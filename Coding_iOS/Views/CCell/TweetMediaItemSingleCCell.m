//
//  TweetMediaItemSingleCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetMediaItemCCellSingle_Width 150.0
#define kTweetMediaItemCCellSingle_MaxHeight (kScreen_Height/2)

#import "TweetMediaItemSingleCCell.h"
#import "UIImageView+WebCache.h"


@implementation TweetMediaItemSingleCCell
@synthesize curMediaItem = _curMediaItem, imgView = _imgView;

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
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, kTweetMediaItemCCellSingle_Width, kTweetMediaItemCCellSingle_Width)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self.contentView addSubview:_imgView];
    }
    
    if (_curMediaItem != curMediaItem) {
        _curMediaItem = curMediaItem;
    }
    __weak typeof(self) weakSelf = self;
    [_imgView sd_setImageWithURL:[_curMediaItem.src urlImageWithCodePathResizeToView:_imgView] placeholderImage:kPlaceholderCodingSquareView(_imgView) options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            if (![ImageSizeManager hasSrc:weakSelf.curMediaItem.src]) {
                [ImageSizeManager saveImage:weakSelf.curMediaItem.src size:image.size];
                if (weakSelf.refreshSingleCCellBlock) {
                    weakSelf.refreshSingleCCellBlock();
                }
            }
        }
    }];
    [_imgView setSize:[self sizeWithSrc:_curMediaItem.src originalWidth:kTweetMediaItemCCellSingle_Width maxHeight:kTweetMediaItemCCellSingle_MaxHeight minWidth:50]];
}

+(CGSize)ccellSizeWithObj:(id)obj{
    CGSize itemSize;
    if ([obj isKindOfClass:[HtmlMediaItem class]]) {
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        itemSize = [self sizeWithSrc:curMediaItem.src originalWidth:kTweetMediaItemCCellSingle_Width maxHeight:kTweetMediaItemCCellSingle_MaxHeight minWidth:50];
    }
    return itemSize;
}

@end
