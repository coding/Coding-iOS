//
//  TopicListButton.h
//  Coding_iOS
//
//  Created by 周文敏 on 15/4/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicListButton : UIButton

+ (instancetype)buttonWithTitle:(NSString *)title andNumber:(NSInteger)number;
+ (instancetype)buttonWithTitle:(NSString *)title;

- (void)setIconHide:(BOOL)hide;

@end
