//
//  UIButton+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIButton+Common.h"
#import "Login.h"

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

@end
