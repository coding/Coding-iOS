//
//  WMDelLabel.m
//  Coding_iOS
//
//  Created by zwm on 15/4/22.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "WMDelLabel.h"

#define kColorLabelText [UIColor colorWithHexString:@"0x3bbd79"]
#define kColorLabelBgColor [UIColor colorWithHexString:@"0xd8f3e4"]

@interface WMDelLabel ()
{
    UITapGestureRecognizer *_singleTap;
    UILongPressGestureRecognizer *_longPressTap;
}
@end

@implementation WMDelLabel

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    self.font = [UIFont systemFontOfSize:12];
    self.textColor = kColorLabelText;
    self.textAlignment = NSTextAlignmentCenter;
    self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.layer.cornerRadius = 11;
    self.layer.backgroundColor = kColorLabelBgColor.CGColor;
    self.layer.borderColor = kColorLabelText.CGColor;
    
//    _longPressTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTapRecognized:)];
//    [self addGestureRecognizer:_longPressTap];
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    [_singleTap setNumberOfTouchesRequired:1];
    [_singleTap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:_singleTap];
    self.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu) name:@"UIMenuControllerWillHideMenuNotification"  object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hideMenu
{
    self.layer.borderWidth = 0;
}

#pragma mark - Callbacks
- (void)longPressTapRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _longPressTap) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            [self becomeFirstResponder];    // must be called even when NS_BLOCK_ASSERTIONS=0
            
            self.layer.borderWidth = 1;
            
            UIMenuController *delMenu = [UIMenuController sharedMenuController];
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(delBtnClick:)];
            NSArray *menuItems = [NSArray arrayWithObjects:item, nil];
            [delMenu setMenuItems:menuItems];
            [delMenu setTargetRect:self.bounds inView:self];
            [delMenu setMenuVisible:YES animated:YES];
        }
    }
}

- (void)singleTapRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _singleTap) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self becomeFirstResponder];    // must be called even when NS_BLOCK_ASSERTIONS=0
            
            self.layer.borderWidth = 1;
            
            UIMenuController *delMenu = [UIMenuController sharedMenuController];
            UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(delBtnClick:)];
            NSArray *menuItems = [NSArray arrayWithObjects:item, nil];
            [delMenu setMenuItems:menuItems];
            [delMenu setTargetRect:self.bounds inView:self];
            [delMenu setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    if (action == @selector(delBtnClick:)) {
        retValue = YES;
    } else {
        // Pass the canPerformAction:withSender: message to the superclass
        // and possibly up the responder chain.
        retValue = [super canPerformAction:action withSender:sender];
    }
    
    return retValue;
}

- (IBAction)delBtnClick:(id)sender
{
    self.layer.borderWidth = 0;
    
    if (self.delLabelDelegate && [self.delLabelDelegate respondsToSelector:@selector(delBtnClick:)]) {
        [self.delLabelDelegate delBtnClick:self];
    }
}

@end
