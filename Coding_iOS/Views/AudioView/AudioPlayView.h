//
//  AudioPlayView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"

@interface AudioPlayView : UIControl <AudioManagerDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) id validator;
@property (readonly, assign) BOOL isDownloading;
@property (readonly, assign) BOOL isPlaying;

- (void)play;
- (void)stop;

- (void)didDownloadStarted;
- (void)didDownloadFinished;
- (void)didDownloadError:(NSError *)error;

@end
