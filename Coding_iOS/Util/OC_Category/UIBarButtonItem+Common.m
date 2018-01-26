//
//  UIBarButtonItem+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/11/5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIBarButtonItem+Common.h"

@implementation UIBarButtonItem (Common)
+ (UIBarButtonItem *)itemWithBtnTitle:(NSString *)title target:(id)obj action:(SEL)selector{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:obj action:selector];
    [buttonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"0x0060FF" andAlpha:.5]} forState:UIControlStateDisabled];
    return buttonItem;
}

@end
