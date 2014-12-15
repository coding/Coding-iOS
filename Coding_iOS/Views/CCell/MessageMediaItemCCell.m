//
//  MessageMediaItemCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "MessageMediaItemCCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#define kMessageCell_ContentWidth (kScreen_Width*0.6)

@implementation MessageMediaItemCCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCurObj:(NSObject *)curObj{
    _curObj = curObj;
    if (!_curObj) {
        return;
    }
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_ContentWidth, kMessageCell_ContentWidth)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 5.0;
        
//        [_imgView doBorderWidth:0.5 color:nil cornerRadius:5.0];
        [self.contentView addSubview:_imgView];
    }
    
    if ([_curObj isKindOfClass:[UIImage class]]) {
        UIImage *curImage = (UIImage *)_curObj;
        self.imgView.image = curImage;
        [_imgView setSize:[self sizeWithImage:curImage originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2]];
    }else if ([_curObj isKindOfClass:[HtmlMediaItem class]]){
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)_curObj;
        __weak typeof(self) weakSelf = self;
        [self.imgView sd_setImageWithURL:[curMediaItem.src urlImageWithCodePathResizeToView:_imgView] placeholderImage:kPlaceholderCodingSquareWidth(150.0) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                HtmlMediaItem *curBlockMediaItem = (HtmlMediaItem *)weakSelf.curObj;
                CGSize imageSize = image.size;
                if (![ImageSizeManager hasSrc:curBlockMediaItem.src]) {
                    [ImageSizeManager saveImage:curBlockMediaItem.src size:imageSize];
                    CGSize reSize = [weakSelf sizeWithImage:image originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
                    if (weakSelf.refreshMessageMediaCCellBlock) {
                        weakSelf.refreshMessageMediaCCellBlock(reSize.height - kMessageCell_ContentWidth);
                    }
                }
            }
        }];
        CGSize reSize = [weakSelf sizeWithSrc:curMediaItem.src originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
        [_imgView setSize:reSize];
    }
}

+(CGSize)ccellSizeWithObj:(NSObject *)obj{
    CGSize itemSize;
    if ([obj isKindOfClass:[UIImage class]]) {
        itemSize = [obj sizeWithImage:(UIImage *)obj originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    }else if ([obj isKindOfClass:[HtmlMediaItem class]]){
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        itemSize = [curMediaItem sizeWithSrc:curMediaItem.src originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    }
    return itemSize;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
