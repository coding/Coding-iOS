//
//  UIBarButtonItem+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/11/5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIBarButtonItem+Common.h"

@implementation UIBarButtonItem (Common)
+ (UIBarButtonItem *)itemWithBtnTitle:(NSString *)title color:(UIColor *)titleColor target:(id)obj action:(SEL)selector{
    UIButton *button = [UIButton buttonWithTitle:title titleColor:titleColor];
    [button addTarget:obj action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

@end
