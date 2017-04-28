//
//  TweetLikeUserCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetCell_LikeUserCCell_Height 30.0

#import "TweetLikeUserCCell.h"

@interface TweetLikeUserCCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *likesLabel;

@end

@implementation TweetLikeUserCCell
- (void)configWithUser:(User *)user rewarded:(BOOL)rewarded{
    if (!self.imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height)];
        self.imgView.layer.masksToBounds = YES;
        self.imgView.layer.cornerRadius = kTweetCell_LikeUserCCell_Height/2;
        self.imgView.layer.borderColor = [UIColor colorWithHexString:@"0xFFAE03"].CGColor;
        [self.contentView addSubview:self.imgView];
    }
    if (user) {
        [self.imgView sd_setImageWithURL:[user.avatar urlImageWithCodePathResizeToView:_imgView] placeholderImage:kPlaceholderMonkeyRoundView(_imgView)];
        if (_likesLabel) {
            _likesLabel.hidden = YES;
        }
    }else{
        [self.imgView sd_setImageWithURL:nil];
        [self.imgView setImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xD8DDE4"]]];
        if (!_likesLabel) {
            _likesLabel = [[UILabel alloc] initWithFrame:_imgView.bounds];
            _likesLabel.backgroundColor = [UIColor clearColor];
            _likesLabel.textColor = [UIColor whiteColor];
            _likesLabel.font = [UIFont systemFontOfSize:15];
            _likesLabel.minimumScaleFactor = 0.5;
            _likesLabel.textAlignment = NSTextAlignmentCenter;
            [self.imgView addSubview:_likesLabel];
        }
        _likesLabel.text = @"···";
        _likesLabel.hidden = NO;
    }
    self.imgView.layer.borderWidth = rewarded? 1.0 : 0.0;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

+(CGSize)ccellSize{
    CGSize itemSize = CGSizeMake(kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height);
    return itemSize;
}
@end
