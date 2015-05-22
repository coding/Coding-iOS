//
//  TaskCommentCCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kTaskCommentCCell_Width 33.0

#import "TaskCommentCCell.h"

@implementation TaskCommentCCell
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
        _imgView = [[YLImageView alloc] initWithFrame:CGRectZero];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    
    if (_curMediaItem != curMediaItem) {
        _curMediaItem = curMediaItem;
        [self.imgView sd_setImageWithURL:[_curMediaItem.src urlImageWithCodePathResize:2*kTaskCommentCCell_Width crop:YES] placeholderImage:kPlaceholderCodingSquareWidth(55.0) options:SDWebImageRetryFailed| SDWebImageLowPriority| SDWebImageHandleCookies];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

+(CGSize)ccellSize{
    return CGSizeMake(kTaskCommentCCell_Width, kTaskCommentCCell_Width);
}

@end
