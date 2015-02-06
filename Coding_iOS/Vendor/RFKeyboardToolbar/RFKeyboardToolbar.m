//
//  RFKeyboardToolbar.m
//
//  Created by Rudd Fawcett on 12/3/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFKeyboardToolbar.h"

@interface RFKeyboardToolbar ()

/**
 *  The toolbar view.
 */
@property (nonatomic,strong) UIView *toolbarView;
/**
 *  The scroll view that's faked to look like a toolbar.
 */
@property (nonatomic,strong) UIScrollView *scrollView;
/**
 *  The fake top border to replicate the toolbar.
 */
@property (nonatomic,strong) CALayer *topBorder;

@end

@implementation RFKeyboardToolbar

+ (instancetype)toolbarWithButtons:(NSArray *)buttons {
    return [[RFKeyboardToolbar alloc] initWithButtons:buttons];
}

+ (instancetype)toolbarViewWithButtons:(NSArray *)buttons {
    return [[RFKeyboardToolbar alloc] initWithButtons:buttons];
}

- (id)initWithButtons:(NSArray *)buttons {
    self = [super initWithFrame:CGRectMake(0, 0, self.window.rootViewController.view.bounds.size.width, 40)];
    if (self) {
        _buttons = [buttons copy];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:[self inputAccessoryView]];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect frame = _toolbarView.bounds;
    frame.size.height = 0.5f;
    
    _topBorder.frame = frame;
}

- (UIView *)inputAccessoryView {
    _toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    _toolbarView.backgroundColor = [UIColor colorWithWhite:0.973 alpha:1.0];
    _toolbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    _topBorder = [CALayer layer];
    _topBorder.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, 0.5f);
    _topBorder.backgroundColor = [UIColor colorWithWhite:0.678 alpha:1.0].CGColor;
    
    [_toolbarView.layer addSublayer:_topBorder];
    [_toolbarView addSubview:[self fakeToolbar]];
    
    return _toolbarView;
}

- (UIScrollView *)fakeToolbar {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentInset = UIEdgeInsetsMake(6.0f, 0.0f, 8.0f, 6.0f);
    
    [self addButtons];
    
    return _scrollView;
}

- (void)addButtons {
    NSUInteger index = 0;
    NSUInteger originX = 8;
    
    CGRect originFrame;
    
    for (RFToolbarButton *eachButton in _buttons) {
        originFrame = CGRectMake(originX, 0, eachButton.frame.size.width, eachButton.frame.size.height);
        eachButton.frame = originFrame;
        
        [_scrollView addSubview:eachButton];
        
        originX = originX + eachButton.bounds.size.width + 8;
        index++;
    }
    
    CGSize contentSize = _scrollView.contentSize;
    contentSize.width = originX - 8;
    _scrollView.contentSize = contentSize;
}

- (void)setButtons:(NSArray *)buttons {
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _buttons = [buttons copy];
    [self addButtons];
}

- (void)setButtons:(NSArray *)buttons animated:(BOOL)animated {
    if (!animated) {
        self.buttons = buttons;
        return;
    }
    
    NSMutableSet *removeButtons = [NSMutableSet setWithArray:_buttons];
    [removeButtons minusSet:[NSSet setWithArray:buttons]];
    NSMutableSet *addButtons = [NSMutableSet setWithArray:buttons];
    [addButtons minusSet:[NSSet setWithArray:_buttons]];
    _buttons = [buttons copy];
    
    // calculate end frames
    NSUInteger originX = 8;
    NSUInteger index = 0;
    NSMutableArray *buttonFrames = [NSMutableArray arrayWithCapacity:_buttons.count];
    
    for (RFToolbarButton *button in _buttons) {
        CGRect frame = CGRectMake(originX, 0, button.frame.size.width, button.frame.size.height);
        [buttonFrames addObject:[NSValue valueWithCGRect:frame]];
        
        originX += button.bounds.size.width + 8;
        index++;
    }
    
    CGSize contentSize = _scrollView.contentSize;
    contentSize.width = originX - 8;
    if (contentSize.width > _scrollView.contentSize.width) {
        _scrollView.contentSize = contentSize;
    }
    
    // make added buttons appear from the right
    [addButtons enumerateObjectsUsingBlock:^(RFToolbarButton *button, BOOL *stop) {
        button.frame = CGRectMake(originX, 0, button.frame.size.width, button.frame.size.height);
        [_scrollView addSubview:button];
    }];
    
    // animate
    [UIView animateWithDuration:0.2 animations:^{
        [removeButtons enumerateObjectsUsingBlock:^(RFToolbarButton *button, BOOL *stop) {
            button.alpha = 0;
        }];
        
        [_buttons enumerateObjectsUsingBlock:^(RFToolbarButton *button, NSUInteger idx, BOOL *stop) {
            button.frame = [buttonFrames[idx] CGRectValue];
        }];
        
        _scrollView.contentSize = contentSize;
    } completion:^(BOOL finished) {
        [removeButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }];
}

@end
