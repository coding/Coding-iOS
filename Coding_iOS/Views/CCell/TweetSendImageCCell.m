//
//  TweetSendImageCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetSendImageCCell_Width floorf((kScreen_Width - 15*2- 10*3)/4)

#import "TweetSendImageCCell.h"

@implementation TweetSendImageCCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setCurTweetImg:(TweetImage *)curTweetImg{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetSendImageCCell_Width, kTweetSendImageCCell_Width)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
//        _imgView.layer.masksToBounds = YES;
//        _imgView.layer.cornerRadius = 2.0;
        [self.contentView addSubview:_imgView];
    }
    _curTweetImg = curTweetImg;
    if (_curTweetImg) {
        if (!_deleteBtn) {
            _deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(kTweetSendImageCCell_Width-20, 0, 20, 20)];
            [_deleteBtn setImage:[UIImage imageNamed:@"btn_delete_tweetimage"] forState:UIControlStateNormal];
            _deleteBtn.backgroundColor = [UIColor blackColor];
            _deleteBtn.layer.cornerRadius = CGRectGetWidth(_deleteBtn.bounds)/2;
            _deleteBtn.layer.masksToBounds = YES;
            
            [_deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_deleteBtn];
        }
        RAC(self.imgView, image) = [RACObserve(self.curTweetImg, thumbnailImage) takeUntil:self.rac_prepareForReuseSignal];
        _deleteBtn.hidden = NO;
    }else{
        _imgView.image = [UIImage imageNamed:@"addPictureBgImage"];
        if (_deleteBtn) {
            _deleteBtn.hidden = YES;
        }
    }
}
- (void)deleteBtnClicked:(id)sender{
    if (_deleteTweetImageBlock) {
        _deleteTweetImageBlock(_curTweetImg);
    }
}
+(CGSize)ccellSize{
    return CGSizeMake(kTweetSendImageCCell_Width, kTweetSendImageCCell_Width);
}

@end
