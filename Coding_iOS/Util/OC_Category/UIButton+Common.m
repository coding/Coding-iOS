//
//  UIButton+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIButton+Common.h"
#import "Login.h"
#import <POP+MCAnimate/POP+MCAnimate.h>
#import <math.h>

@implementation UIButton (Common)
+ (UIButton *)buttonWithTitle:(NSString *)title titleColor:(UIColor *)color{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:kBackButtonFontSize]];
    [btn.titleLabel setMinimumScaleFactor:0.5];
    
    CGFloat titleWidth = [title getWidthWithFont:btn.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, 30)] +20;
    btn.frame = CGRectMake(0, 0, titleWidth, 30);
    
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}
+ (UIButton *)buttonWithTitle_ForNav:(NSString *)title{
    return [UIButton buttonWithTitle:title titleColor:[UIColor colorWithHexString:@"0x3bbd79"]];
}
+ (UIButton *)buttonWithUserStyle{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn userNameStyle];
    return btn;
}

- (void)frameToFitTitle{
    CGRect frame = self.frame;
    CGFloat titleWidth = [self.titleLabel.text getWidthWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(kScreen_Width, frame.size.height)];
    frame.size.width = titleWidth;
    [self setFrame:frame];
}

- (void)userNameStyle{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2.0;
    self.titleLabel.font = [UIFont systemFontOfSize:17];
//    [self setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
}
- (void)setUserTitle:(NSString *)aUserName{
    [self setTitle:aUserName forState:UIControlStateNormal];
    [self frameToFitTitle];
}
- (void)setUserTitle:(NSString *)aUserName font:(UIFont *)font maxWidth:(CGFloat)maxWidth{
    [self setTitle:aUserName forState:UIControlStateNormal];
    CGRect frame = self.frame;
    CGFloat titleWidth = [self.titleLabel.text getWidthWithFont:font constrainedToSize:CGSizeMake(kScreen_Width, frame.size.height)];
    if (titleWidth > maxWidth) {
        titleWidth = maxWidth;
//        self.titleLabel.minimumScaleFactor = 0.5;
//        self.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    [self setWidth:titleWidth];
    [self.titleLabel setWidth:titleWidth];
}
- (void)configFollowBtnWithUser:(User *)curUser fromCell:(BOOL)fromCell{
//    对于自己，要隐藏
    if ([Login isLoginUserGlobalKey:curUser.global_key]) {
        self.hidden = YES;
        return;
    }else{
        self.hidden = NO;
    }
    
    NSString *imageName;
    if (curUser.followed.boolValue) {
        if (curUser.follow.boolValue) {
            imageName = @"btn_followed_both";
        }else{
            imageName = @"btn_followed_yes";
        }
    }else{
        imageName = @"btn_followed_not";
    }
//    if (fromCell) {
//        imageName = [imageName stringByAppendingString:@"_cell"];
//    }
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}
+ (UIButton *)btnFollowWithUser:(User *)curUser{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
    [btn configFollowBtnWithUser:curUser fromCell:NO];
    return btn;
}

- (void)configPriMsgBtnWithUser:(User *)curUser fromCell:(BOOL)fromCell{
//    对于自己，要隐藏
    if ([Login isLoginUserGlobalKey:curUser.global_key]) {
        self.hidden = YES;
        return;
    }else{
        self.hidden = NO;
    }
    
    NSString *imageName;
    if (curUser.followed.boolValue && !fromCell) {
        imageName = @"btn_privateMsg_friend";
    }else{
        imageName = @"btn_privateMsg_stranger";
    }
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}
+ (UIButton *)btnPriMsgWithUser:(User *)curUser{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
    [btn configPriMsgBtnWithUser:curUser fromCell:NO];
    return btn;
}

+ (UIButton *)tweetBtnWithFrame:(CGRect)frame image:(NSString *)imageName{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button doBorderWidth:0.5 color:[UIColor colorWithHexString:@"0xCCCCCC"] cornerRadius:CGRectGetHeight(button.frame)/2];
    return button;
}
- (void)animateToImage:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        return;
    }
    [self setImage:image forState:UIControlStateNormal];
    if ([self superview]) {
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.frame = self.imageView.frame;
        
        UIView *superV = [self superview];
        CGPoint superCenterP = [self convertPoint:imageV.center toView:superV];
        imageV.center = superCenterP;
        [superV addSubview:imageV];

        //animate and remove subview
        [NSObject pop_animate:^{
            CGPoint centerP = imageV.center;
            centerP.x += CGRectGetWidth(self.frame) /2;
            centerP.y -= CGRectGetHeight(self.frame) *2;
            imageV.pop_velocity.center = imageV.center;
            imageV.pop_springBounciness = 10;
            imageV.pop_springSpeed = 5;
            imageV.pop_spring.center = centerP;
            
            imageV.layer.pop_rotation = M_PI_4/2;
            imageV.pop_scaleXY = CGPointMake(2.0, 2.0);
            imageV.pop_spring.alpha = 0.5;
        } completion:^(BOOL finished) {
            [NSObject pop_animate:^{
                CGPoint centerP = imageV.center;
                centerP.y -= CGRectGetHeight(self.frame);
                imageV.pop_easeInEaseOut.center = centerP;
                imageV.pop_spring.alpha = 0;
            } completion:^(BOOL finished) {
                [imageV removeFromSuperview];
            }];
        }];
    }
}
@end
