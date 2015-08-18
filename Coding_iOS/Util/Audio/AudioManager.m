//
//  AudioManager.m
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioManager.h"
#import "AudioAmrUtil.h"

@interface AudioManager () <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) NSString *tmpFile;
@property (nonatomic, strong) NSTimer *meterTimer;

@end

@implementation AudioManager

+ (instancetype)shared {
    static id obj = nil;
    if (obj == nil) {
        obj = [[self alloc] init];
    }
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isPlaying = NO;
        _isRecording = NO;
        _minRecordDuration = 1.0f;
        _maxRecordDuration = 60.0f;
    }
    return self;
}

- (void)play:(NSString *)file validator:(id)validator {
    [self stopPlay];
    [self stopRecord];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
        return;
    }
    NSError *err;
    NSURL *url = [NSURL fileURLWithPath:file isDirectory:NO];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    if (err) {
        if(_delegate && [_delegate respondsToSelector:@selector(didAudioPlay:err:)]) {
            [_delegate didAudioPlay:self err:err];
        }
        [self stopPlay];
        return;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    _audioPlayer.delegate = self;
    _audioPlayer.volume = 1.0f;
//    _audioPlayer.meteringEnabled = YES;
    [_audioPlayer play];
    _validator = validator;
    _isPlaying = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didAudioPlayStarted:)]) {
        [_delegate didAudioPlayStarted:self];
    }
}

- (void)stopPlay {
    [self stopPlay:NO];
}

- (void)stopPlay:(BOOL)successfully {
    if (_audioPlayer) {
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    if (_isPlaying) {
        _isPlaying = NO;
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioPlayStoped:successfully:)]) {
            [_delegate didAudioPlayStoped:self successfully:successfully];
        }
    }
}

- (void)record {
    [self stopPlay];
    [self stopRecord];
    
    NSDictionary *settings = @{AVSampleRateKey:@8000,
                               AVFormatIDKey:[NSNumber numberWithInt:kAudioFormatLinearPCM],
                               AVNumberOfChannelsKey:@1,
                               AVLinearPCMBitDepthKey:@16,
                               AVLinearPCMIsNonInterleaved:@NO,
                               AVLinearPCMIsFloatKey:@NO,
                               AVLinearPCMIsBigEndianKey:@NO};
    
    _tmpFile = [[self class] tmpFile];
    NSError *err;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:_tmpFile]
                                                 settings:settings
                                                    error:&err];
    if (err) {
        if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecord:err:)]) {
            [_delegate didAudioRecord:self err:err];
        }
        [self stopRecord];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error: nil];
    
    _isRecording = YES;
    __weak typeof(self) weakSelf = self;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            if (weakSelf.isRecording) {
                weakSelf.audioRecorder.delegate = weakSelf;
                weakSelf.audioRecorder.meteringEnabled = YES;
                [weakSelf.audioRecorder record];
                weakSelf.validator = nil;
                [weakSelf startUpdateMeter];
                
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didAudioRecordStarted:)]) {
                    [weakSelf.delegate didAudioRecordStarted:weakSelf];
                }
            }
        }
        else {
            _isRecording = NO;
            kTipAlert(@"没有权限");
        }
    }];
}

- (void)stopRecord {
    [self stopRecord:YES];
}

- (void)stopRecord:(BOOL)successfully {
    [self stopUpdateMeter];
    NSTimeInterval duration = 0;
    if (_audioRecorder) {
        duration = _audioRecorder.currentTime;
        [_audioRecorder stop];
        _audioRecorder = nil;
    }
    if (_isRecording) {
        _isRecording = NO;
        if (duration < _minRecordDuration) {
            if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecord:err:)]) {
                [_delegate didAudioRecord:self err:[NSError errorWithDomain:@"录音时间过短" code:200 userInfo:nil]];
            }
        }
        else {
            NSString *recordFile = [AudioAmrUtil encodeWaveToAmr:_tmpFile];
            if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecordStoped:file:duration:successfully:)]) {
                [_delegate didAudioRecordStoped:self file:recordFile duration:duration successfully:successfully];
            }
        }
        //remove tmp file
        [[NSFileManager defaultManager] removeItemAtPath:_tmpFile error:nil];
        _tmpFile = nil;
    }
}

- (void)stopAll {
    if (_isPlaying) {
        [self stopPlay];
    }
    if (_isRecording) {
        [self stopRecord];
    }
}

- (void)startUpdateMeter {
    self.meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeter) userInfo:nil repeats:YES];
}

- (void)stopUpdateMeter {
    if (_meterTimer) {
        [_meterTimer invalidate];
        self.meterTimer = nil;
    }
}

- (void)updateMeter {
    [_audioRecorder updateMeters];
    
    double volume; // The linear 0.0 .. 1.0 value we need.
    float minDecibels = -80.0f; // Or use -60dB, which I measured in a silent room.
    float decibels = [_audioRecorder averagePowerForChannel:0];
    
    if (decibels < minDecibels) {
        volume = 0.0f;
    } else if (decibels >= 0.0f) {
        volume = 1.0f;
    } else {
        float root = 2.0f;
        float minAmp = powf(10.0f, 0.05f * minDecibels);
        float inverseAmpRange = 1.0f / (1.0f - minAmp);
        float amp = powf(10.0f, 0.05f * decibels);
        float adjAmp = (amp - minAmp) * inverseAmpRange;
        
        volume = pow(adjAmp, 1.0f / root);
    }

    if (_delegate && [_delegate respondsToSelector:@selector(didAudioRecording:volume:)]) {
        [_delegate didAudioRecording:self volume:volume];
    }
    
    if (_audioRecorder.currentTime >= _maxRecordDuration+0.1f) {
        [self stopRecord];
    }
}

#pragma mark - Dir

+ (NSString *)tmpFile {
    NSString *dir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"AudioRecord"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *file = [[dir stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"caf"];
    return file;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)vplayer successfully:(BOOL)flag {
    [self stopPlay:flag];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)vplayer error:(NSError *)error {
    [self stopPlay];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)vplayer {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [self stopPlay];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)vplayer withFlags:(NSUInteger)flags {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)vrecorder successfully:(BOOL)flag {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)vrecorder error:(NSError *)error {
    [self stopRecord:NO];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)vrecorder {
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [self stopRecord:NO];
}

@end
