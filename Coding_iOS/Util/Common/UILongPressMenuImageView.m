//
//  UILongPressMenuImageView.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/25.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UILongPressMenuImageView.h"
#import <objc/runtime.h>

@implementation UILongPressMenuImageView

#pragma mark LongCopyMenu

- (BOOL)canBecomeFirstResponder{
    if (self.longPressMenuBlock) {
        return YES;
    }else{
        return [super canBecomeFirstResponder];
    }
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (self.longPressMenuBlock) {
        for (int i=0; i<self.longPressTitles.count; i++) {
            if (action == NSSelectorFromString([NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i])) {
                return YES;
            }
        }
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}


- (void)addLongPressMenu:(NSArray *)titles clickBlock:(void(^)(NSInteger index, NSString *title))block{
    self.longPressMenuBlock = block;
    self.longPressTitles = titles;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:longPress];
}

-(void)handleLongPress:(UIGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:self.longPressTitles.count];
        Class cls = [self class];
        SEL imp = @selector(longPressMenuClicked:);
        for (int i=0; i<self.longPressTitles.count; i++) {
            NSString *title = [self.longPressTitles objectAtIndex:i];
//            注册名添加方法sel，sel的具体实现在imp(longPressMenuClicked:)
            SEL sel = sel_registerName([[NSString stringWithFormat:@"easeLongPressMenuClicked_%d:", i] UTF8String]);
            class_addMethod(cls, sel, [cls instanceMethodForSelector:imp], "v@");
            UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:sel];
            [menuItems addObject:menuItem];
        }
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setMenuItems:menuItems];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
- (void)longPressMenuClicked:(id)sender {
    NSString *selStr = NSStringFromSelector(_cmd);
    NSString *preFix = @"easeLongPressMenuClicked_";
    NSString *indexStr = [selStr substringFromIndex:preFix.length];
    NSInteger index = indexStr.integerValue;
    if (index >=0 && index<self.longPressTitles.count) {
        NSString *title = [self.longPressTitles objectAtIndex:index];
        if (self.longPressMenuBlock) {
            self.longPressMenuBlock(index, title);
        }
    }
}

@end
