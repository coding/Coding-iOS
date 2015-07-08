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
        
        self.iconImageView = [[GlowImageView alloc] initWithFrame:CGRectMake(0, 0, menuItem.iconImage.size.width, menuItem.iconImage.size.height)];
        self.iconImageView.userInteractionEnabled = NO;
        [self.iconImageView setImage:menuItem.iconImage forState:UIControlStateNormal];
        self.iconImageView.glowColor = menuItem.glowColor;
        self.iconImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.iconImageView.bounds));
        [self addSubview:self.iconImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.iconImageView.frame), CGRectGetWidth(self.bounds), 35)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
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
    // 播放缩放动画
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
    scaleAnimation.springBounciness = 20;    // value between 0-20
    scaleAnimation.springSpeed = 20;     // value between 0-20
    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.3, 1.3)];
    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self disMissCompleted:NULL];
}

- (void)disMissCompleted:(void(^)(BOOL finished))completed {
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animation];
    scaleAnimation.springBounciness = 16;    // value between 0-20
    scaleAnimation.springSpeed = 14;     // value between 0-20
    scaleAnimation.property = [POPAnimatableProperty propertyWithName:kPOPViewScaleXY];
    scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
    scaleAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (completed) {
            completed(finished);
        }
    };
    [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimationKey"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 回调
    [self disMissCompleted:^(BOOL finished) {
        if (self.didSelctedItemCompleted) {
            self.didSelctedItemCompleted(self.menuItem);
        }
    }];
}

@end
