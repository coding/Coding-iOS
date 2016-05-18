//
//  TopicHotkeyView.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TopicHotkeyBlock)(NSDictionary *topic);

@interface TopicHotkeyView : UIView
@property (nonatomic, copy) TopicHotkeyBlock block;
- (void)setHotkeys:(NSArray *)hotkeys;
@end
