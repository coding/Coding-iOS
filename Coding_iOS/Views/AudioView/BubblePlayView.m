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
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

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
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _activityView.hidesWhenStopped = YES;
        [_activityView stopAnimating];
        [self addSubview:_activityView];
        
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
        playImage = [UIImage imageNamed:@"bubble_right_play_2"];
    }
    else {
        bgImage = [UIImage imageNamed:@"messageLeft_bg_img"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        playImage = [UIImage imageNamed:@"bubble_left_play_2"];
    }
    _bgImageView.image = bgImage;
    _playImageView.size = playImage.size;
    _playImageView.image = playImage;
    //refresh play state
    self.playState = self.playState;
    
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

- (void)setPlayState:(AudioPlayViewState)playState {
    [super setPlayState:playState];
    if (playState == AudioPlayViewStatePlaying) {
        [_activityView stopAnimating];
        [self startPlayingAnimation];
    }
    else if (playState == AudioPlayViewStateDownloading) {
        [_activityView startAnimating];
        [self stopPlayingAnimation];
    }
    else {
        [_activityView stopAnimating];
        [self stopPlayingAnimation];
    }
}

#pragma mark - Animation

- (void)startPlayingAnimation {
    _playImageView.image = nil;
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_right_play_" duration:0.8];
    }
    else {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_left_play_" duration:0.8];
    }
    [_playImageView startAnimating];
}

- (void)stopPlayingAnimation {
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"bubble_right_play_2"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"bubble_left_play_2"];
    }
}

@end
