//
//  BubblePlayView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioPlayView.h"

typedef NS_ENUM(NSInteger, BubbleType) {
    BubbleTypeLeft,
    BubbleTypeRight
};

@interface BubblePlayView : AudioPlayView

@property (nonatomic, assign) BubbleType type;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL showBgImg;
@property (nonatomic, assign) BOOL isUnread;

+ (CGFloat)widthForDuration:(NSTimeInterval)duration;

@end
