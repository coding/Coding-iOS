//
//  MenuButton.m
//  JackFastKit
//
//  Created by 曾 宪华 on 14-10-13.
//  Copyright (c) 2014年 华捷 iOS软件开发工程师 曾宪华. All rights reserved.
//

#import "MenuButton.h"
#import <POP.h>

// Model
#import "MenuItem.h"

// View
#import "GlowImageView.h"

@interface MenuButton ()

@property (nonatomic, strong) GlowImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) MenuItem *menuItem;

@end

@implementation MenuButton

- (instancetype)initWithFrame:(CGRect)frame menuItem:(MenuItem *)menuItem {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.menuItem = menuItem;
        
        CGSize imageSize = menuItem.iconImage.size;
        if (!kDevice_Is_iPhone6Plus && !kDevice_Is_iPhone6) {
            imageSize = CGSizeMake(imageSize.width *0.9, imageSize.height *0.9);
        }
        self.iconImageView = [[GlowImageView alloc] initWithFrame:CGRectMake(0, 0, imageSize.width, imageSize.height)];
        self.iconImageView.userInteractionEnabled = NO;
        [self.iconImageView setImage:menuItem.iconImage forState:UIControlStateNormal];
        self.iconImageView.glowColor = menuItem.glowColor;
        self.iconImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.iconImageView.bounds));
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame) + 20, CGRectGetWidth(self.bounds), 20)];
        self.titleLabel.textColor = kColorDark4;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.text = menuItem.title;
        CGPoint center = self.titleLabel.center;
        center.x = CGRectGetMidX(self.bounds);
        self.titleLabel.center = center;
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self popBegan];
}

- (void)popBegan{
    self.alpha = 0.7;
    
//    [self pop_removeAllAnimations];
//    // 播放缩放动画
//    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
//    scaleAnimation.springBounciness = 20;    // value between 0-20
//    scaleAnimation.springSpeed = 20;     // value between 0-20
//    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
//    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
//    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self disMissCompleted:NULL];
}

- (void)disMissCompleted:(void(^)(BOOL finished))completed {
    self.alpha = 1.0;

    if (completed) {
        completed(YES);
    }
//    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
//    scaleAnimation.springBounciness = 16;    // value between 0-20
//    scaleAnimation.springSpeed = 14;     // value between 0-20
//    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
//    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
//    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
//        if (completed) {
//            completed(finished);
//        }
//    };
//    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *curTouch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [curTouch locationInView:self]) &&
        !CGRectContainsPoint(self.bounds, [curTouch previousLocationInView:self])) {
        [self popBegan];
    }else if (!CGRectContainsPoint(self.bounds, [curTouch locationInView:self]) &&
              CGRectContainsPoint(self.bounds, [curTouch previousLocationInView:self])){
        [self disMissCompleted:NULL];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *curTouch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [curTouch locationInView:self])) {
        // 回调
        [self disMissCompleted:^(BOOL finished) {
            if (self.didSelctedItemCompleted) {
                self.didSelctedItemCompleted(self.menuItem);
            }
        }];
    }else{
        [self disMissCompleted:NULL];
    }
}

@end
