//
//  AudioRecordView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AudioRecordViewTouchState) {
    AudioRecordViewTouchStateInside,
    AudioRecordViewTouchStateOutside
};

@protocol AudioRecordViewDelegate;

@interface AudioRecordView : UIControl

@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) id<AudioRecordViewDelegate> delegate;

@end

@protocol AudioRecordViewDelegate <NSObject>

@optional

- (void)recordViewRecordStarted:(AudioRecordView *)recordView;
- (void)recordViewRecordFinished:(AudioRecordView *)recordView file:(NSString *)file duration:(NSTimeInterval)duration;
- (void)recordView:(AudioRecordView *)recordView touchStateChanged:(AudioRecordViewTouchState)touchState;
- (void)recordView:(AudioRecordView *)recordView volume:(double)volume;
- (void)recordViewRecord:(AudioRecordView *)recordView err:(NSError *)err;

@end