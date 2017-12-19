//
//  AMPopTip+Exit.m
//  AMPopTip
//
//  Created by Valerio Mazzeo on 09/02/2016.
//  Copyright © 2016 Valerio Mazzeo. All rights reserved.
//

#import "AMPopTip+Exit.h"

@implementation AMPopTip (Exit)

- (void)performExitAnimation:(void (^)())completion {
    switch (self.exitAnimation) {
        case AMPopTipExitAnimationScale: {
            [self exitScale:completion];
            break;
        }
        case AMPopTipExitAnimationFadeOut: {
            [self exitFadeOut:completion];
            break;
        }
        case AMPopTipExitAnimationCustom: {
            [self.containerView addSubview:self];
            if (self.exitAnimationHandler) {
                self.exitAnimationHandler(^{
                    if (completion) {
                        completion();
                    }
                });
            }
            break;
        }
        case AMPopTipExitAnimationNone: {
            [self.containerView addSubview:self];
            if (completion) {
                completion();
            }
            break;
        }
        default: {
            [self.containerView addSubview:self];
            if (completion) {
                completion();
            }
            break;
        }
    }
}

- (void)exitScale:(void (^)())completion {
    self.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:self.animationOut delay:self.delayOut options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.transform = CGAffineTransformMakeScale(0.000001, 0.000001);
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

- (void)exitFadeOut:(void (^)())completion {
    self.alpha = 1.0;
    [UIView animateWithDuration:self.animationOut delay:self.delayOut options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL completed){
        if (completed && completion) {
            completion();
        }
    }];
}

@end
