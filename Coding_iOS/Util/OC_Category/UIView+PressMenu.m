//
//  UIView+PressMenu.m
//  Coding_iOS
//
//  Created by Ease on 15/6/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//


#import "UIView+PressMenu.h"
#import <objc/runtime.h>

@implementation UIView (PressMenu)

static const NSString *kPressMenuSelectorPrefix = @"easePressMenuClicked_";
static char PressMenuTitlesKey, PressMenuBlockKey, PressMenuGestureKey, MenuVCKey;

#pragma mark M
- (void)addPressMenuTitles:(NSArray *)menuTitles menuClickedBlock:(void(^)(NSInteger index, NSString *title))block{
    self.userInteractionEnabled = YES;
    self.menuClickedBlock = block;
    self.menuTitles = menuTitles;
    if (self.pressGR == nil) {
        self.pressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    }
    [self addGestureRecognizer:self.pressGR];
}

- (void)showMenuTitles:(NSArray *)menuTitles menuClickedBlock:(void(^)(NSInteger index, NSString *title))block{
    self.menuClickedBlock = block;
    self.menuTitles = menuTitles;
    [self p_showMenu];
}

- (BOOL)isMenuVCVisible{
    if (self.menuVC) {
        return [self.menuVC isMenuVisible];
    }
    return NO;
}

- (void)removePressMenu{
    if (self.menuVC) {
        [self.menuVC setMenuVisible:NO animated:YES];
        self.menuVC = nil;
    }
    if ([self.pressGR isKindOfClass:[UILongPressGestureRecognizer class]]) {
        [self removeGestureRecognizer:self.pressGR];
        self.pressGR = nil;
    }
    if (self.menuClickedBlock) {
        self.menuClickedBlock = nil;
    }
    if (self.menuTitles) {
        self.menuTitles = nil;
    }
}

#pragma mark SET_GET
- (void)setMenuTitles:(NSArray *)menuTitles{
    objc_setAssociatedObject(self, &PressMenuTitlesKey, menuTitles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSArray *)menuTitles{
    return objc_getAssociatedObject(self, &PressMenuTitlesKey);
}

- (void)setMenuClickedBlock:(void (^)(NSInteger, NSString *))menuClickedBlock{
    objc_setAssociatedObject(self, &PressMenuBlockKey, menuClickedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(NSInteger, NSString *))menuClickedBlock{
    return objc_getAssociatedObject(self, &PressMenuBlockKey);
}

- (void)setPressGR:(UILongPressGestureRecognizer *)pressGR{
    objc_setAssociatedObject(self, &PressMenuGestureKey, pressGR, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UILongPressGestureRecognizer *)pressGR{
    return objc_getAssociatedObject(self, &PressMenuGestureKey);
}

- (void)setMenuVC:(UIMenuController *)menuVC{
    objc_setAssociatedObject(self, &MenuVCKey, menuVC, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIMenuController *)menuVC{
    return objc_getAssociatedObject(self, &MenuVCKey);
}

#pragma mark canPerformAction
- (BOOL)canBecomeFirstResponder{
    if (self.menuClickedBlock) {
        return YES;
    }else{
        return [super canBecomeFirstResponder];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (self.menuClickedBlock) {
        for (int i=0; i<self.menuTitles.count; i++) {
            if (action == NSSelectorFromString([NSString stringWithFormat:@"%@%d:", kPressMenuSelectorPrefix, i])) {
                return YES;
            }
        }
        return NO;
    }else{
        return [super canPerformAction:action withSender:sender];
    }
}

-(void)handlePress:(UIGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self p_showMenu];
    }
}

- (void)p_showMenu{
    [self becomeFirstResponder];
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:self.menuTitles.count];
    Class cls = [self class];
    SEL imp = @selector(pressMenuClicked:);
    for (int i=0; i<self.menuTitles.count; i++) {
        NSString *title = [self.menuTitles objectAtIndex:i];
        //注册名添加方法sel，sel的具体实现在imp(pressMenuClicked:)
        SEL sel = sel_registerName([[NSString stringWithFormat:@"%@%d:", kPressMenuSelectorPrefix, i] UTF8String]);
        class_addMethod(cls, sel, [cls instanceMethodForSelector:imp], "v@");
        UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:title action:sel];
        [menuItems addObject:menuItem];
    }
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:menuItems];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    self.menuVC = menu;
}

- (void)pressMenuClicked:(id)sender {
    NSString *selStr = NSStringFromSelector(_cmd);
    NSString *indexStr = [selStr substringFromIndex:kPressMenuSelectorPrefix.length];
    NSInteger index = indexStr.integerValue;
    if (index >=0 && index<self.menuTitles.count) {
        NSString *title = [self.menuTitles objectAtIndex:index];
        if (self.menuClickedBlock) {
            self.menuClickedBlock(index, title);
        }
    }
}

@end
