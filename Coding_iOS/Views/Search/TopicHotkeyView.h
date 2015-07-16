//
//  TopicHotkeyView.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopicHotkeyViewDelegate <NSObject>

- (void)didClickHotkeyWithIndex:(NSInteger)index;

@end

@interface TopicHotkeyView : UIView

@property (nonatomic, assign) id<TopicHotkeyViewDelegate> delegate;

- (void)setHotkeys:(NSArray *)hotkeys;

@end
