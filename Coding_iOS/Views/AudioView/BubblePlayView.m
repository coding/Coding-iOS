//
//  BubblePlayView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "BubblePlayView.h"

@interface BubblePlayView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILabel *durationLbl;

@end

@implementation BubblePlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_bgImageView];
        
        _playImageView = [[UIImageView alloc] init];
        [self addSubview:_playImageView];
        
        _durationLbl = [[UILabel alloc] init];
        _durationLbl.backgroundColor = [UIColor clearColor];
        _durationLbl.font = [UIFont systemFontOfSize:16];
        _durationLbl.textColor = [UIColor blackColor];
        [self addSubview:_durationLbl];
        
        self.showBgImg = YES;
        self.type = BubbleTypeLeft;
        self.duration = 0;
    }
    return self;
}

- (void)sizeToFit {
    [super sizeToFit];
    if (_type == BubbleTypeRight) {
        [_playImageView setOrigin:CGPointMake(16, (self.frame.size.height-_playImageView.frame.size.height)/2-1)];
        [_durationLbl setOrigin:CGPointMake(16+8+_playImageView.frame.size.height, (self.frame.size.height-_durationLbl.frame.size.height)/2-1)];
    }
    else {
        [_playImageView setOrigin:CGPointMake(self.frame.size.width-_playImageView.frame.size.width-16, (self.frame.size.height-_playImageView.frame.size.height)/2-1)];
        [_durationLbl setOrigin:CGPointMake(self.frame.size.width-_playImageView.frame.size.width-16-8-_durationLbl.frame.size.width, (self.frame.size.height-_durationLbl.frame.size.height)/2-1)];
    }
}

- (void)setType:(BubbleType)type {
    _type = type;
    UIImage *bgImage = nil;
    UIImage *playImage = nil;
    if (type == BubbleTypeRight) {
        bgImage = [UIImage imageNamed:@"messageRight_bg_img"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        playImage = [UIImage imageNamed:@"add_user_icon"];
    }
    else {
        bgImage = [UIImage imageNamed:@"messageLeft_bg_img"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        playImage = [UIImage imageNamed:@"add_user_icon"];
    }
    _bgImageView.image = bgImage;
    _playImageView.size = playImage.size;
    _playImageView.image = playImage;
    
    [self sizeToFit];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    if (duration < 0) {
        _duration = 0;
    }
    
    _durationLbl.text = [NSString stringWithFormat:@"%d''", (int)_duration];
    [_durationLbl sizeToFit];
    
    [self sizeToFit];
}

- (void)setShowBgImg:(BOOL)showBgImg {
    _showBgImg = showBgImg;
    _bgImageView.hidden = !showBgImg;
}

#pragma mark - Download

- (void)didDownloadStarted {
    
}

- (void)didDownloadFinished {
    
}

- (void)didDownloadError:(NSError *)error {
    
}

#pragma mark - AudioManagerDelegate

- (void)didAudioPlayStarted:(AudioManager *)am {
    [super didAudioPlayStarted:am];
//    if (_type == BubbleTypeRight) {
//        _playImageView.image = [UIImage animatedImageNamed:@"bubble_right_playing_" duration:1];
//    }
//    else {
//        _playImageView.image = [UIImage animatedImageNamed:@"bubble_left_playing_" duration:1];
//    }
//    [_playImageView startAnimating];
}

- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    [super didAudioPlayStoped:am successfully:successfully];
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    [super didAudioPlay:am err:err];
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
}

@end
