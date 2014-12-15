//
//  UIUnderlinedButton.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIUnderlinedButton : UIButton
+ (UIUnderlinedButton *)underlinedButton;
+ (UIUnderlinedButton *)buttonWithTitle:(NSString *)title andFont:(UIFont *)font andColor:(UIColor *)color;

@end
