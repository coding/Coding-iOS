//
//  AudioRecordView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioRecordView.h"
#import "AudioManager.h"

@interface AudioRecordView () <AudioManagerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) AudioRecordViewTouchState touchState;

@end

@implementation AudioRecordView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initAudioRecordView];
    }
    return self;
}

- (void)initAudioRecordView {
    self.backgroundColor = [UIColor colorWithRGBHex:0x2faeea];
    self.layer.cornerRadius = self.frame.size.width/2;
    
    _isRecording = NO;
    
    [self addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(onTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
}

- (void)record {
    [self stop];
    
    _isRecording = YES;
    [AudioManager shared].delegate = self;
    [[AudioManager shared] recordWithValidator:_validator];
    
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordStarted:)]) {
        [_delegate recordViewRecordStarted:self];
    }
}

- (void)stop {
    _isRecording = NO;
    [[AudioManager shared] stopPlay];
}

- (void)onTouchDown:(id)sender {
    [self record];
}

- (void)onTouchUpInside:(id)sender {
    [[AudioManager shared] stopRecord];
}

- (void)onTouchUpOutside:(id)sender {
    [[AudioManager shared] stopRecord];
}

#pragma mark - touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    _touchState = AudioRecordViewTouchStateInside;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    BOOL touchInside = [self pointInside:[touch locationInView:self] withEvent:nil];
    BOOL touchStateChanged = NO;
    if (_touchState == AudioRecordViewTouchStateInside && !touchInside) {
        _touchState = AudioRecordViewTouchStateOutside;
        touchStateChanged = YES;
    }
    else if (_touchState == AudioRecordViewTouchStateOutside && touchInside) {
        _touchState = AudioRecordViewTouchStateInside;
        touchStateChanged = YES;
    }
    if (touchStateChanged) {
        if (_delegate && [_delegate respondsToSelector:@selector(recordView:touchStateChanged:)]) {
            [_delegate recordView:self touchStateChanged:_touchState];
        }
    }
}

#pragma mark - AudioManagerDelegate

- (void)didAudioRecordStarted:(AudioManager *)am {
    
}

- (void)didAudioRecording:(AudioManager *)am volume:(double)volume {
    if (_delegate && [_delegate respondsToSelector:@selector(recordView:volume:)]) {
        [_delegate recordView:self volume:volume];
    }
}

- (void)didAudioRecordStoped:(AudioManager *)am file:(NSString *)file duration:(NSTimeInterval)duration successfully:(BOOL)successfully {
    _isRecording = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(recordViewRecordFinished:file:duration:)]) {
        [_delegate recordViewRecordFinished:self file:file duration:duration];
    }
}

- (void)didAudioRecord:(AudioManager *)am err:(NSError *)err {
    _isRecording = NO;
}

@end
