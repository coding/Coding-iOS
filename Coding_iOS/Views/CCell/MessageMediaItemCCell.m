//
//  MessageMediaItemCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-17.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "MessageMediaItemCCell.h"

#define kMessageCell_ContentWidth (0.6 *kScreen_Width)

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
        _imgView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, kMessageCell_ContentWidth, kMessageCell_ContentWidth)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 6.0;
        
//        [_imgView doBorderWidth:0.5 color:nil cornerRadius:5.0];
        [self.contentView addSubview:_imgView];
    }
    
    if ([_curObj isKindOfClass:[UIImage class]]) {
        UIImage *curImage = (UIImage *)_curObj;
        self.imgView.image = curImage;
        [_imgView setSize:[[ImageSizeManager shareManager] sizeWithImage:curImage originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2]];
    }else if ([_curObj isKindOfClass:[HtmlMediaItem class]]){
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)_curObj;
        NSURL *currentImageURL = [curMediaItem.src urlImageWithCodePathResizeToView:_imgView];
        __weak typeof(self) weakSelf = self;
        [self.imgView sd_setImageWithURL:currentImageURL placeholderImage:kPlaceholderCodingSquareWidth(150.0) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if ([weakSelf.curObj isKindOfClass:[HtmlMediaItem class]]) {
                HtmlMediaItem *curBlockMediaItem = (HtmlMediaItem *)weakSelf.curObj;
                if (image && [imageURL.absoluteString isEqualToString:currentImageURL.absoluteString]) {
                    CGSize imageSize = image.size;
                    if (![[ImageSizeManager shareManager] hasSrc:curBlockMediaItem.src]) {
                        [[ImageSizeManager shareManager] saveImage:curBlockMediaItem.src size:imageSize];
                        CGSize reSize = [[ImageSizeManager shareManager] sizeWithImage:image originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
                        if (weakSelf.refreshMessageMediaCCellBlock) {
                            weakSelf.refreshMessageMediaCCellBlock(reSize.height - kMessageCell_ContentWidth);
                        }
                    }
                }
            }
        }];
        
        CGSize reSize = CGSizeZero;
        if ([self.reuseIdentifier isEqualToString:kCCellIdentifier_MessageMediaItem_Single]) {
            reSize = [MessageMediaItemCCell monkeyCcellSize];
        }else{
            reSize = [MessageMediaItemCCell ccellSizeWithObj:_curObj];
        }
        [_imgView setSize:reSize];
    }
}

+(CGSize)ccellSizeWithObj:(NSObject *)obj{
    CGSize itemSize;
    if ([obj isKindOfClass:[UIImage class]]) {
        itemSize = [[ImageSizeManager shareManager] sizeWithImage:(UIImage *)obj originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    }else if ([obj isKindOfClass:[VoiceMedia class]]) {
        itemSize = CGSizeMake(kMessageCell_ContentWidth, 40);
    }else if ([obj isKindOfClass:[HtmlMediaItem class]]){
        HtmlMediaItem *curMediaItem = (HtmlMediaItem *)obj;
        itemSize = [[ImageSizeManager shareManager] sizeWithSrc:curMediaItem.src originalWidth:kMessageCell_ContentWidth maxHeight:kScreen_Height/2];
    }
    return itemSize;
}

+(CGSize)monkeyCcellSize{
    CGFloat width = kScaleFrom_iPhone5_Desgin(100);
    return CGSizeMake(width, width);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
