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

@interface UIButton ()
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@end

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
    return [UIButton buttonWithTitle:title titleColor:kColorBrandGreen];
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
//    [self setTitleColor:kColor222 forState:UIControlStateNormal];
    [self setTitleColor:kColorBrandGreen forState:UIControlStateNormal];
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
    CGFloat titleWidth = [self.titleLabel.text getWidthWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, frame.size.height)];
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

+ (UIButton *)tweetBtnWithFrame:(CGRect)frame alignmentLeft:(BOOL)alignmentLeft{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:kColor999 forState:UIControlStateNormal];
    if (alignmentLeft) {
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    }else{
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    }
    return button;
}
- (void)animateToImage:(NSString *)imageName{
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        return;
    }
    [self setImage:image forState:UIControlStateNormal];
    if ([self superview]) {
        UIView *superV = [self superview];
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        CGRect vFrame = [self convertRect:self.imageView.frame toView:superV];
        imageV.frame = vFrame;
        [superV addSubview:imageV];

        //animate
        CGAffineTransform fromTransform = imageV.transform;
        CGPoint fromCenter = imageV.center;
        CGFloat dx = CGRectGetWidth(self.frame) /2;
        CGFloat dy = CGRectGetHeight(self.frame) *3;
        CGFloat dScale = 3.0;
        CGFloat dRotation = M_PI_4;

        NSTimeInterval moveDurarion = 1.0;
        POPCustomAnimation *moveA = [POPCustomAnimation animationWithBlock:^BOOL(id target, POPCustomAnimation *animation) {
            float time_percent = (animation.currentTime - animation.beginTime)/moveDurarion;
            UIView *view = (UIView *)target;
            CGPoint toCenter = CGPointMake(fromCenter.x + time_percent * dx, fromCenter.y - (dy * time_percent * (2 - time_percent)));//抛物线移动
            view.center = toCenter;
            
            CGAffineTransform toTransform = fromTransform;
            toTransform = CGAffineTransformTranslate(toTransform, 50, -50);

            CGFloat toScale = 1 + time_percent *(dScale - 1);//线性放大
            toTransform = CGAffineTransformMakeScale(toScale, toScale);
            CGFloat toRotation = dRotation * (1- cosf(time_percent * M_PI_2));//cos曲线旋转（先慢后快）
            toTransform = CGAffineTransformRotate(toTransform, toRotation);
            view.transform = toTransform;
            
            view.alpha = 1 - time_percent;
            return time_percent < 1.0;
        }];
        [imageV pop_addAnimation:moveA forKey:@"animateToImage"];
    }
}
#pragma mark -
//开始请求时，UIActivityIndicatorView 提示
static char EAActivityIndicatorKey;
- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator{
    objc_setAssociatedObject(self, &EAActivityIndicatorKey, activityIndicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
- (UIActivityIndicatorView *)activityIndicator{
    return objc_getAssociatedObject(self, &EAActivityIndicatorKey);
}

- (void)startQueryAnimate{
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];
        [self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    [self.activityIndicator startAnimating];
    self.enabled = NO;
}
- (void)stopQueryAnimate{
    [self.activityIndicator stopAnimating];
    self.enabled = YES;
}
@end
