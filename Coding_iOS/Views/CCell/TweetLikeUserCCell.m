//
//  TweetLikeUserCCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetCell_LikeUserCCell_Height 25.0

#import "TweetLikeUserCCell.h"

@interface TweetLikeUserCCell ()
@property (strong, nonatomic) User *curUser;
@property (strong, nonatomic) NSNumber *likes;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *likesLabel;

@end

@implementation TweetLikeUserCCell
- (void)configWithUser:(User *)user likesNum:(NSNumber *)likes{
    self.curUser = user;
    self.likes = likes;
    
    if (!self.imgView) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTweetCell_LikeUserCCell_Height, kTweetCell_LikeUserCCell_Height)];
        [self.imgView doCircleFrame];
        [self.contentView addSubview:self.imgView];
    }
    if (_curUser) {
        [self.imgView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_imgView] placeholderImage:kPlaceholderMonkeyRoundView(_imgView)];
        if (_likesLabel) {
            _likesLabel.hidden = YES;
        }
    }else{
        [self.imgView sd_setImageWithURL:nil];
        [self.imgView setImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"0xdadada"]]];
        if (!_likesLabel) {
            _likesLabel = [[UILabel alloc] initWithFrame:_imgView.frame];
            _likesLabel.backgroundColor = [UIColor clearColor];
            _likesLabel.textColor = [UIColor whiteColor];
            _likesLabel.font = [UIFont systemFontOfSize:15];
            _likesLabel.minimumScaleFactor = 0.5;
            _likesLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:_likesLabel];
        }
        _likesLabel.text = [NSString stringWithFormat:@"%d", _likes.intValue];
        _likesLabel.hidden = NO;
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
}


@end
