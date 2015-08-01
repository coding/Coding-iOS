//
//  BubblePlayView.h
//  audiodemo
//
//  Created by sumeng on 7/30/15.
//  Copyright (c) 2015 sumeng. All rights reserved.
//

#import "AudioPlayView.h"

typedef enum _BubbleType {
    BubbleTypeLeft = 0,
    BubbleTypeRight = 1
}BubbleType;

@interface BubblePlayView : AudioPlayView

@property (nonatomic, assign) BubbleType type;
@property (nonatomic, assign) NSTimeInterval duration;

@end
