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

- (id)validator {
    if (_validator) {
        return _validator;
    }
    else {
        return _url;
    }
}

- (void)play {
    [self stop];
    
    if (_url == nil) {
        return;
    }
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
    
    _isPlaying = YES;
    [AudioManager shared].delegate = self;
    [[AudioManager shared] play:f validator:self.validator];
}

- (void)stop {
    _isPlaying = NO;
    [[AudioManager shared] stopPlay];
}

- (void)onClicked:(id)sender {
    _isPlaying ? [self stop] : [self play];
}

#pragma mark - Download

- (void)startDownload:(NSURL *)url {
    if (url == nil) {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask = [[Coding_FileManager af_manager] downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath:[[self class] downloadFile:response.URL.absoluteString]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            [self didDownloadError:error];
        }
        else {
            if ([self.validator isEqual:[AudioManager shared].validator]) {
                [self play:filePath.path];
            }
            [self didDownloadFinished];
        }
    }];
    [downloadTask resume];
    [self didDownloadStarted];
}

- (void)didDownloadStarted {
    
}

- (void)didDownloadFinished {
    
}

- (void)didDownloadError:(NSError *)error {
    
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
    _isPlaying = NO;
}

- (void)didAudioPlay:(AudioManager *)am err:(NSError *)err {
    _isPlaying = NO;
}

@end
