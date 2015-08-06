//
//  TweetMediaItemCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetMediaItemCCell_Width ((kScreen_Width - 36.0)/3.0)

#import "TweetMediaItemCCell.h"

@interface TweetMediaItemCCell ()
@end


@implementation TweetMediaItemCCell

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
        _imgView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetMediaItemCCell_Width, kTweetMediaItemCCell_Width)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
//        _imgView.layer.masksToBounds = YES;
//        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
    }

    
    if (_curMediaItem != curMediaItem) {
        _curMediaItem = curMediaItem;
        [self.imgView sd_setImageWithURL:[_curMediaItem.src urlImageWithCodePathResize:2*kTweetMediaItemCCell_Width crop:YES] placeholderImage:kPlaceholderCodingSquareWidth(80.0)  options:SDWebImageRetryFailed];
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
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
}
+(CGSize)ccellSizeWithObj:(id)obj{
    CGSize itemSize;
    if ([obj isKindOfClass:[HtmlMediaItem class]]) {
        itemSize = CGSizeMake(kTweetMediaItemCCell_Width, kTweetMediaItemCCell_Width);
    }
    return itemSize;
}

@end
