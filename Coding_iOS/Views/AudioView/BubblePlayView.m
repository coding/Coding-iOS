//
//  BubblePlayView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "BubblePlayView.h"

#define kBubblePlayViewMinWidth (kScreen_Width*0.23)
#define kBubblePlayViewMidWidth (kScreen_Width*0.35)
#define kBubblePlayViewMaxWidth (kScreen_Width*0.6)

@interface BubblePlayView ()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *playImageView;
@property (nonatomic, strong) UILabel *durationLbl;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView *unreadView;

@end

@implementation BubblePlayView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
        _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _activityView.hidesWhenStopped = YES;
        [_activityView stopAnimating];
        [self addSubview:_activityView];
        
        _unreadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
        _unreadView.backgroundColor = [UIColor colorWithRGBHex:0xf75288];
        _unreadView.layer.cornerRadius = _unreadView.frame.size.width/2;
        _unreadView.hidden = YES;
        [self addSubview:_unreadView];
        
        self.showBgImg = YES;
        self.isUnread = NO;
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
        _unreadView.center = CGPointMake(-5, self.frame.size.height/2-1);
    }
    else {
        [_playImageView setOrigin:CGPointMake(self.frame.size.width-_playImageView.frame.size.width-16, (self.frame.size.height-_playImageView.frame.size.height)/2-1)];
        [_durationLbl setOrigin:CGPointMake(self.frame.size.width-_playImageView.frame.size.width-16-8-_durationLbl.frame.size.width, (self.frame.size.height-_durationLbl.frame.size.height)/2-1)];
        _unreadView.center = CGPointMake(self.frame.size.width+5, self.frame.size.height/2-1);
    }
}

- (void)setType:(BubbleType)type {
    _type = type;
    UIImage *bgImage = nil;
    UIImage *bgHlImage = nil;
    UIImage *playImage = nil;
    if (type == BubbleTypeRight) {
        bgImage = [UIImage imageNamed:@"messageRight_bg_img"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        bgHlImage = [UIImage imageNamed:@"messageRight_bg_highlight_img"];
        bgHlImage = [bgHlImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        playImage = [UIImage imageNamed:@"bubble_right_play_2"];
    }
    else {
        bgImage = [UIImage imageNamed:@"messageLeft_bg_img"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        bgHlImage = [UIImage imageNamed:@"messageLeft_bg_highlight_img"];
        bgHlImage = [bgHlImage resizableImageWithCapInsets:UIEdgeInsetsMake(18, 30, bgImage.size.height - 19, bgImage.size.width - 31)];
        playImage = [UIImage imageNamed:@"bubble_left_play_2"];
    }
    _bgImageView.image = bgImage;
    _bgImageView.highlightedImage = bgHlImage;
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
    
    _durationLbl.text = [NSString stringWithFormat:@"%d\"", (int)_duration];
    [_durationLbl sizeToFit];
    
    [self setWidth:[[self class] widthForDuration:_duration]];
    
    [self sizeToFit];
}

- (void)setShowBgImg:(BOOL)showBgImg {
    _showBgImg = showBgImg;
    _bgImageView.hidden = !showBgImg;
}

- (void)setIsUnread:(BOOL)isUnread {
    _isUnread = isUnread;
    _unreadView.hidden = !isUnread;
}

- (void)setPlayState:(AudioPlayViewState)playState {
    [super setPlayState:playState];
    if (playState == AudioPlayViewStatePlaying) {
        [_activityView stopAnimating];
        [self startPlayingAnimation];
    }
    else if (playState == AudioPlayViewStateDownloading) {
//        [_activityView startAnimating];
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

#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _bgImageView.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    //在TableViewCell中，快速点击不显示highlight状态
    [self performSelector:@selector(cancelHighlight) withObject:nil afterDelay:0.1f];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    _bgImageView.highlighted = NO;
}

- (void)cancelHighlight {
    _bgImageView.highlighted = NO;
}

#pragma mark - Width

+ (CGFloat)widthForDuration:(NSTimeInterval)duration {
    if (duration < 0) {
        duration = 0;
    }
    else if (duration > 60.0f) {
        duration = 60.0f;
    }
    
    if (duration <= 10.0f) {
        return kBubblePlayViewMinWidth + (kBubblePlayViewMidWidth - kBubblePlayViewMinWidth) * (duration / 10);
    }
    else {
        return kBubblePlayViewMidWidth + (kBubblePlayViewMaxWidth - kBubblePlayViewMidWidth) * ((duration - 10) / 50);
    }
}

@end
