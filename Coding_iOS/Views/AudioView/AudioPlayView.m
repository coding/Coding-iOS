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
#import "Coding_FileManager.h"

@interface AudioPlayView ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id validator;

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
    self.playState = AudioPlayViewStateNormal;
    [self addTarget:self action:@selector(onClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setUrl:(NSURL *)url {
    [self setUrl:url validator:url];
}

- (void)setUrl:(NSURL *)url validator:(id)validator {
    _url = url;
    _validator = validator;
    if ([[AudioManager shared].validator isEqual:validator] && [AudioManager shared].isPlaying) {
        [AudioManager shared].delegate = self;
        self.playState = AudioPlayViewStatePlaying;
    }
    else if ([[AudioManager shared].validator isEqual:validator] && [self isDownloading:url]) {
        [AudioManager shared].delegate = self;
        self.playState = AudioPlayViewStateDownloading;
    }
    else {
        self.playState = AudioPlayViewStateNormal;
    }
}

- (void)play {
    [self stop];
    
    if (_url == nil) {
        return;
    }
    
    if ([[AudioManager shared].delegate isKindOfClass:[AudioPlayView class]]
        && [AudioManager shared].delegate != self) {
        AudioPlayView *view = (AudioPlayView *)[AudioManager shared].delegate;
        if (view.playState == AudioPlayViewStateDownloading) {
            view.playState = AudioPlayViewStateNormal;
        }
    }
    [AudioManager shared].delegate = self;
    
    if ([_url isFileURL]) {
        [self play:_url.path];
    }
    else {
        NSString *file = [[self class] downloadFile:_url.absoluteString];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
            [self play:file];
        }
        else {
            [AudioManager shared].validator = self.validator;
            [self startDownload:_url];
        }
    }
}

- (void)play:(NSString *)file {
    [self stop];
    if (file.length == 0) {
        return;
    }
    
    NSString *f = nil;
    if ([@"amr" isEqualToString:file.pathExtension]) {
        f = [AudioAmrUtil convertedWaveFromAmr:file];
        if (f == nil) {
            f = [AudioAmrUtil decodeAmrToWave:file];
        }
    }
    else {
        f = file;
    }
    
    self.playState = AudioPlayViewStatePlaying;
    [[AudioManager shared] play:f validator:self.validator];
    
    if (_playStartedBlock) {
        _playStartedBlock(self);
    }
}

- (void)stop {
    self.playState = AudioPlayViewStateNormal;
    [[AudioManager shared] stopPlay];
}

- (void)onClicked:(id)sender {
    if (_playState == AudioPlayViewStatePlaying) {
        [self stop];
    }
    else if (_playState == AudioPlayViewStateNormal) {
        [self play];
    }
}

#pragma mark - Download

- (void)startDownload:(NSURL *)url {
    if (url == nil) {
        return;
    }
    if (![self isDownloading:url]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSProgress *progress;
        NSURLSessionDownloadTask *downloadTask = [[Coding_FileManager af_manager] downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:[[self class] downloadFile:response.URL.absoluteString]];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (error) {
                [self didDownloadError:error];
                self.playState = AudioPlayViewStateNormal;
            }
            else {
                if ([self.validator isEqual:[AudioManager shared].validator]) {
                    [self play:filePath.path];
                }
                else {
                    self.playState = AudioPlayViewStateNormal;
                }
            }
        }];
        [downloadTask resume];
    }
    self.playState = AudioPlayViewStateDownloading;
}

- (void)didDownloadError:(NSError *)error {
    
}

- (BOOL)isDownloading:(NSURL *)url {
    for (NSURLSessionDownloadTask *downloadTask in [Coding_FileManager af_manager].downloadTasks) {
        if ([downloadTask.originalRequest.URL isEqual:url]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - FileManager

+ (NSString *)downloadDir {
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dir = [docDir stringByAppendingPathComponent:@"AudioDownload"];
    [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
    return dir;
}

+ (NSString *)downloadFile:(NSString *)url {
    NSString *file = [[url md5Str] stringByAppendingPathExtension:[url pathExtension]];
    return [[self downloadDir] stringByAppendingPathComponent:file];
}

+ (BOOL)cleanCache {
    return [[NSFileManager defaultManager] removeItemAtPath:[self downloadDir] error:nil];
}

#pragma mark - AudioManagerDelegate

- (void)didAudioPlayStarted:(AudioManager *)am {
    
}

- (void)didAudioPlayStoped:(AudioManager *)am successfully:(BOOL)successfully {
    self.playState = AudioPlayViewStateNormal;
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    self.playState = AudioPlayViewStateNormal;
    [NSObject showHudTipStr:err.domain];
}

@end
