//
//  AMPopTip+Entrance.m
//  AMPopTip
//
//  Created by Andrea Mazzini on 10/06/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

#import "AMPopTip+Entrance.h"

@implementation AMPopTip (Entrance)

- (void)performEntranceAnimation:(void (^)())completion {
    switch (self.entranceAnimation) {
        case AMPopTipEntranceAnimationScale: {
            [self entranceScale:completion];
            break;
        }
        case AMPopTipEntranceAnimationTransition: {
            [self entranceTransition:completion];
            break;
        }
        case AMPopTipEntranceAnimationFadeIn: {
            [self entranceFadeIn:completion];
            break;
        }
        case AMPopTipEntranceAnimationCustom: {
            [self.containerView addSubview:self];
            if (self.entranceAnimationHandler) {
                self.entranceAnimationHandler(^{
                    completion();
                });
            }
        }
        case AMPopTipEntranceAnimationNone: {
            [self.containerView addSubview:self];
            completion();
            break;
        }
        default: {
            [self.containerView addSubview:self];
            completion();
            break;
        }
    }
}

- (void)entranceTransition:(void (^)())completion {
    self.transform = CGAffineTransformMakeScale(0.6, 0.6);
    switch (self.direction) {
        case AMPopTipDirectionUp:
            self.transform = CGAffineTransformTranslate(self.transform, 0, -self.fromFrame.origin.y);
            break;
        case AMPopTipDirectionDown:
            self.transform = CGAffineTransformTranslate(self.transform, 0, (self.containerView.frame.size.height - self.fromFrame.origin.y));
            break;
        case AMPopTipDirectionLeft:
            self.transform = CGAffineTransformTranslate(self.transform, -self.fromFrame.origin.x, 0);
            break;
        case AMPopTipDirectionRight:
            self.transform = CGAffineTransformTranslate(self.transform, (self.containerView.frame.size.width - self.fromFrame.origin.x), 0);
            break;
        case AMPopTipDirectionNone:
            self.transform = CGAffineTransformTranslate(self.transform, 0, (self.containerView.frame.size.height - self.fromFrame.origin.y));
            break;

        default:
            break;
    }
    [self.containerView addSubview:self];

    [UIView animateWithDuration:self.animationIn delay:self.delayIn usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)entranceScale:(void (^)())completion {
    self.transform = CGAffineTransformMakeScale(0, 0);
    [self.containerView addSubview:self];

    [UIView animateWithDuration:self.animationIn delay:self.delayIn usingSpringWithDamping:0.6 initialSpringVelocity:1.5 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)entranceFadeIn:(void (^)())completion {
    [self.containerView addSubview:self];
    
    self.alpha = 0.0;
    [UIView animateWithDuration:self.animationIn delay:self.delayIn options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

@end
