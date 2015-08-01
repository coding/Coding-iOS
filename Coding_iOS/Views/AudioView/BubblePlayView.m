//
//  BubblePlayView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "BubblePlayView.h"

#define kBubblePlayViewBubbleMaxWidth 120.0f
#define kBubblePlayViewBubbleMinWidth 60.0f
#define kBubblePlayViewMaxDuration 60

@interface BubblePlayView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILabel *durationLbl;

@end

@implementation BubblePlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgImageView = [[UIImageView alloc] init];
        [self addSubview:_bgImageView];
        
        _playImageView = [[UIImageView alloc] init];
        [self addSubview:_playImageView];
        
        _durationLbl = [[UILabel alloc] init];
        _durationLbl.backgroundColor = [UIColor clearColor];
        _durationLbl.font = [UIFont systemFontOfSize:11];
        _durationLbl.textColor = [UIColor lightGrayColor];
        [self addSubview:_durationLbl];
        
        self.type = BubbleTypeLeft;
        self.duration = 0;
    }
    return self;
}

- (void)sizeToFit {
    [super sizeToFit];
    
    CGFloat bubbleWidth = [self bubbleWidthWithDuration:_duration];
    self.width = _durationLbl.frame.size.width + 10 + bubbleWidth;
    _bgImageView.size = CGSizeMake(bubbleWidth, self.frame.size.height);
    
    if (_type == BubbleTypeRight) {
//        _durationLbl.leftCenter = CGPointMake(0, self.height/2);
//        _bgImageView.rightCenter = CGPointMake(self.width, self.height/2);
//        _playImageView.rightCenter = CGPointMake(self.width-10, self.height/2);
    }
    else {
//        _durationLbl.rightCenter = CGPointMake(self.width, self.height/2);
//        _bgImageView.leftCenter = CGPointMake(0, self.height/2);
//        _playImageView.leftCenter = CGPointMake(10, self.height/2);
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _bgImageView.highlighted = highlighted;
}

- (void)setType:(BubbleType)type {
    _type = type;
    UIImage *bgImage = nil;
    UIImage *bgHighlightedImage = nil;
    UIImage *playImage = nil;
    if (type == BubbleTypeRight) {
//        bgImage = [UIImage stretchImage:@"bubble_right_bg"];
//        bgHighlightedImage = [UIImage stretchImage:@"bubble_right_bg_highlight"];
//        playImage = [UIImage imageNamed:@"bubble_right_playing"];
    }
    else {
//        bgImage = [UIImage stretchImage:@"bubble_left_bg"];
//        bgHighlightedImage = [UIImage stretchImage:@"bubble_left_bg_highlight"];
//        playImage = [UIImage imageNamed:@"bubble_left_playing"];
    }
    _bgImageView.image = bgImage;
    _bgImageView.highlightedImage = bgHighlightedImage;
    _playImageView.size = playImage.size;
    _playImageView.image = playImage;
    
    [self sizeToFit];
}

- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    if (duration < 0) {
        _duration = 0;
    }
    else if (duration >= kBubblePlayViewMaxDuration) {
        _duration = kBubblePlayViewMaxDuration;
    }
    
    _durationLbl.text = [NSString stringWithFormat:@"%d''", (int)_duration];
    [_durationLbl sizeToFit];
    
    [self sizeToFit];
}

- (CGFloat)bubbleWidthWithDuration:(NSInteger)duration {
    return kBubblePlayViewBubbleMinWidth + (kBubblePlayViewBubbleMaxWidth - kBubblePlayViewBubbleMinWidth) * (duration / kBubblePlayViewMaxDuration);
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
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_right_playing_" duration:1];
    }
    else {
        _playImageView.image = [UIImage animatedImageNamed:@"bubble_left_playing_" duration:1];
    }
    [_playImageView startAnimating];
}

- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    [super didAudioPlayStoped:am successfully:successfully];
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"bubble_right_playing"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"bubble_left_playing"];
    }
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    [super didAudioPlay:am err:err];
    [_playImageView stopAnimating];
    if (_type == BubbleTypeRight) {
        _playImageView.image = [UIImage imageNamed:@"bubble_right_playing"];
    }
    else {
        _playImageView.image = [UIImage imageNamed:@"bubble_left_playing"];
    }
}

@end
