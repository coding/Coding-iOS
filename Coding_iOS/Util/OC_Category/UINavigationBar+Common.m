//
//  UINavigationBar+Common.m
//  CodingMart
//
//  Created by Ease on 16/3/22.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "UINavigationBar+Common.h"

@implementation UINavigationBar (Common)
- (void)setupBrandStyle{
    self.translucent = NO;
    [self setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self setShadowImage:nil];
    self.barTintColor = kColorBrandBlue;
    [self p_hideBorderInView:self];
}
- (void)setupClearBGStyle{
//    self.translucent = YES;
//    [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//    [self setShadowImage:[UIImage new]];
//    self.barTintColor = [UIColor clearColor];
    [self setBackgroundImage:[UIImage imageWithColor:kColorWhite] forBarMetrics:UIBarMetricsDefault];
    [self p_hideBorderInView:self];
}

- (BOOL)p_hideBorderInView:(UIView *)view{
    if ([view isKindOfClass:[UIImageView class]]
        && view.frame.size.height <= 1) {
        view.hidden = YES;
        return YES;
    }
    for (UIView *subView in view.subviews) {
        if ([self p_hideBorderInView:subView]) {
            return YES;
        }
    }
    return NO;
}
@end
