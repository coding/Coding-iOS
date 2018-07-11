//
//  UIAlertController+Common.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/7/10.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Common)

#pragma mark kTipAlert
+ (void)ea_showTipStr:(NSString *)tipStr;

#pragma mark ActionSheet
+ (instancetype)ea_actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))block;
- (void)showInView:(UIView *)view;

#pragma mark Alert
+ (instancetype)ea_alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))block;
- (void)show;

@end
