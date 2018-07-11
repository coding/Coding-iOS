//
//  UIAlertController+Common.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/7/10.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "UIAlertController+Common.h"

@implementation UIAlertController (Common)

+ (void)ea_showTipStr:(NSString *)tipStr{
    if (tipStr.length <= 0) {
        return;
    }
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:tipStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelA = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
    [alertCtrl addAction:cancelA];
    [[BaseViewController presentingVC] presentViewController:alertCtrl animated:YES completion:nil];
}

+ (instancetype)ea_actionSheetCustomWithTitle:(NSString *)title buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))block{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    void (^handler)(UIAlertAction *) = ^(UIAlertAction *action){
        NSInteger index = [alertCtrl.actions indexOfObject:action];
        if (block) {
            block(action, index);
        }
    };
    if (buttonTitles && buttonTitles.count > 0) {
        for (NSString *buttonTitle in buttonTitles) {
            [alertCtrl addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:handler]];
        }
    }
    if (destructiveTitle) {
        [alertCtrl addAction:[UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:handler]];
    }
    if (cancelTitle) {
        [alertCtrl addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:handler]];
    }
    return alertCtrl;
}

- (void)showInView:(UIView *)view{
    [self show];
}

+ (instancetype)ea_alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles destructiveTitle:(NSString *)destructiveTitle cancelTitle:(NSString *)cancelTitle andDidDismissBlock:(void (^)(UIAlertAction *action, NSInteger index))block{
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    void (^handler)(UIAlertAction *) = ^(UIAlertAction *action){
        NSInteger index = [alertCtrl.actions indexOfObject:action];
        if (block) {
            block(action, index);
        }
    };
    if (buttonTitles && buttonTitles.count > 0) {
        for (NSString *buttonTitle in buttonTitles) {
            [alertCtrl addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:handler]];
        }
    }
    if (destructiveTitle) {
        [alertCtrl addAction:[UIAlertAction actionWithTitle:destructiveTitle style:UIAlertActionStyleDestructive handler:handler]];
    }
    if (cancelTitle) {
        [alertCtrl addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:handler]];
    }
    return alertCtrl;
}

- (void)show{
    [[BaseViewController presentingVC] presentViewController:self animated:YES completion:nil];
}

@end
