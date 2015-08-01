//
//  AudioPlayView.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioPlayView.h"
#import "AudioManager.h"
#import "AudioAmrUtil.h"

@interface AudioPlayView ()

@end

@implementation AudioPlayView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initAudioPlayView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initAudioPlayView];
    }
    return self;
}

- (void)initAudioPlayView {
    _isPlaying = NO;
    [self addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)play {
    [self stop];
    
    if (_url == nil) {
        return;
    }
    NSString *file = nil;
    if ([_url isFileURL]) {
        NSString *audioFile = _url.path;
        if ([@"amr" isEqualToString:audioFile.pathExtension]) {
            file = [AudioAmrUtil convertedWaveFromAmr:audioFile];
            if (file == nil) {
                file = [AudioAmrUtil decodeAmrToWave:audioFile];
            }
        }
        else {
            file = audioFile;
        }
    }
    
    _isPlaying = YES;
    [AudioManager shared].delegate = self;
    [[AudioManager shared] play:file validator:_validator];
}

- (void)stop {
    _isPlaying = NO;
    [[AudioManager shared] stopPlay];
}

- (void)onClicked:(id)sender {
    _isPlaying ? [self stop] : [self play];
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
    
}

- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    _isPlaying = NO;
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    _isPlaying = NO;
}

@end
