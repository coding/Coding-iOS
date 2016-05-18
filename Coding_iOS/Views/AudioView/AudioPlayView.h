//
//  AudioPlayView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioManager.h"

typedef NS_ENUM(NSInteger, AudioPlayViewState) {
    AudioPlayViewStateNormal,
    AudioPlayViewStateDownloading,
    AudioPlayViewStatePlaying
};

@interface AudioPlayView : UIControl <AudioManagerDelegate>

@property (nonatomic, assign) AudioPlayViewState playState;
@property (nonatomic, copy) void(^playStartedBlock)(AudioPlayView *);

- (void)setUrl:(NSURL *)url;
- (void)setUrl:(NSURL *)url validator:(id)validator;

- (void)play;
- (void)stop;

- (void)didDownloadError:(NSError *)error;

+ (BOOL)cleanCache;

@end
