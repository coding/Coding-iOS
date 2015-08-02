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

#pragma mark - Animation

- (void)startPlayingAnimation {
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"btn_file_cancel"], [UIImage imageNamed:@"btn_file_reDo"], [UIImage imageNamed:@"button_download_cancel"]] duration:0.8];
    }
    else {
        _playImageView.image = [UIImage animatedImageWithImages:@[[UIImage imageNamed:@"btn_file_cancel"], [UIImage imageNamed:@"btn_file_reDo"], [UIImage imageNamed:@"button_download_cancel"]] duration:0.8];
    }
    [_playImageView startAnimating];
}

- (void)stopPlayingAnimation {
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"add_user_icon"];
    }
}

#pragma mark - Download

- (void)didDownloadStarted {
    [_activityView startAnimating];
}

- (void)didDownloadFinished {
    [_activityView stopAnimating];
}

- (void)didDownloadError:(NSError *)error {
    [_activityView stopAnimating];
}

#pragma mark - AudioManagerDelegate

- (void)didAudioPlayStarted:(AudioManager *)am {
    [super didAudioPlayStarted:am];
    [self startPlayingAnimation];
}

- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    [super didAudioPlayStoped:am successfully:successfully];
    [self stopPlayingAnimation];
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    [super didAudioPlay:am err:err];
    [self stopPlayingAnimation];
}

@end
