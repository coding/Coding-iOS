//
//  AMPopTip+Animation.m
//  AMPopTip
//
//  Created by Andrea Mazzini on 10/06/15.
//  Copyright (c) 2015 Fancy Pixel. All rights reserved.
//

#import "AMPopTip+Animation.h"
#import <objc/runtime.h>

@implementation AMPopTip (Animation)

- (void)setShouldBounce:(BOOL)shouldBounce { objc_setAssociatedObject(self, @selector(shouldBounce), [NSNumber numberWithBool:shouldBounce], OBJC_ASSOCIATION_RETAIN);}
- (BOOL)shouldBounce { return [objc_getAssociatedObject(self, @selector(shouldBounce)) boolValue]; }

- (void)performActionAnimation {
    switch (self.actionAnimation) {
        case AMPopTipActionAnimationBounce:
            self.shouldBounce = YES;
            [self bounceAnimation];
            break;
        case AMPopTipActionAnimationFloat:
            [self floatAnimation];
            break;
        case AMPopTipActionAnimationPulse:
            [self pulseAnimation];
            break;
        case AMPopTipActionAnimationNone:
            return;
            break;
        default:
            break;
    }
}

- (void)floatAnimation {
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    switch (self.direction) {
        case AMPopTipDirectionUp:
            yOffset = -self.actionFloatOffset;
            break;
        case AMPopTipDirectionDown:
            yOffset = self.actionFloatOffset;
            break;
        case AMPopTipDirectionLeft:
            xOffset = -self.actionFloatOffset;
            break;
        case AMPopTipDirectionRight:
            xOffset = self.actionFloatOffset;
            break;
        case AMPopTipDirectionNone:
            yOffset = -self.actionFloatOffset;
            break;
    }

    [UIView animateWithDuration:(self.actionAnimationIn / 2) delay:self.actionDelayIn options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
    } completion:nil];
}

- (void)bounceAnimation {
    CGFloat xOffset = 0;
    CGFloat yOffset = 0;
    switch (self.direction) {
        case AMPopTipDirectionUp:
            yOffset = -self.actionBounceOffset;
            break;
        case AMPopTipDirectionDown:
            yOffset = self.actionBounceOffset;
            break;
        case AMPopTipDirectionLeft:
            xOffset = -self.actionBounceOffset;
            break;
        case AMPopTipDirectionRight:
            xOffset = self.actionBounceOffset;
            break;
        case AMPopTipDirectionNone:
            yOffset = -self.actionBounceOffset;
            break;
    }

    [UIView animateWithDuration:(self.actionAnimationIn / 10) delay:self.actionDelayIn options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeTranslation(xOffset, yOffset);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:(self.actionAnimationIn - self.actionAnimationIn / 10) delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:1 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL done) {
            if (self.shouldBounce && done) {
                [self bounceAnimation];
            }
        }];
    }];
}

- (void)pulseAnimation {
    [UIView animateWithDuration:(self.actionAnimationIn / 2) delay:self.actionDelayIn options:(UIViewAnimationOptionRepeat | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction) animations:^{
        self.transform = CGAffineTransformMakeScale(self.actionPulseOffset, self.actionPulseOffset);
    } completion:nil];
}

- (void)dismissActionAnimation {
    self.shouldBounce = NO;
    [UIView animateWithDuration:(self.actionAnimationOut / 2) delay:self.actionDelayOut options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.layer removeAllAnimations];
    }];
}

@end
