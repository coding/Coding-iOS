//
//  UITTTAttributedLabel.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-8.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UITTTAttributedLabel.h"

@interface UITTTAttributedLabel ()
@property (nonatomic, assign) BOOL isSelectedForMenu;
@property (nonatomic, copy) UITTTLabelTapBlock tapBlock;
@property (nonatomic, copy) UITTTLabelTapBlock deleteBlock;
@property (nonatomic, copy) UIColor *copyingColor;
@end

@implementation UITTTAttributedLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _deleteBlock = nil;
        self.copyingColor = [UIColor colorWithHexString:@"0xc0c1c2"];
//        self.leading = 0.0;//行间距，像素值
    }
    return self;
}

#pragma mark Tap
-(void)addTapBlock:(void(^)(id aObj))block{
    _tapBlock = block;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
}
-(void)addDeleteBlock:(UITTTLabelTapBlock)block{
    _deleteBlock = block;
}
-(void)handleTap:(UIGestureRecognizer*) recognizer{
    if (_tapBlock) {
        _tapBlock(self);
    }
}


#pragma mark LongPress
-(void)addLongPressForCopy{
    _isSelectedForMenu = NO;
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePress:)];
    [self addGestureRecognizer:press];
}
-(void)addLongPressForCopyWithBGColor:(UIColor *)color{
    self.copyingColor = color;
    [self addLongPressForCopy];
}
-(void)handlePress:(UIGestureRecognizer*) recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!_isSelectedForMenu) {
            _isSelectedForMenu = YES;
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(menuControllerWillHide:)
                                                         name:UIMenuControllerWillHideMenuNotification
                                                       object:nil];
            [self becomeFirstResponder];
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setTargetRect:self.frame inView:self.superview];
            [menu setMenuVisible:YES animated:YES];
            self.backgroundColor = self.copyingColor;
        }
    }
}

- (void)menuControllerWillHide:(NSNotification*)notification{
    if (_isSelectedForMenu) {
        _isSelectedForMenu = NO;
        self.backgroundColor = [UIColor clearColor];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

//UIMenuController
- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    BOOL canPerformAction = NO;
    if (action == @selector(copy:)) {
        canPerformAction = YES;
    }else if (action == @selector(delete:) && _deleteBlock){
        canPerformAction = YES;
    }
    return canPerformAction;
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
}

- (void)delete:(__unused id)sender {
    if (_deleteBlock) {
        _deleteBlock(self);
    }
}

@end
