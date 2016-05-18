//
//  UIActionSheet+Front.m
//  Coding_iOS
//
//  Created by Ease on 15/10/13.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "UIActionSheet+Front.h"
#import <objc/runtime.h>

@implementation UIActionSheet (Front)
- (void)customShowInView:(UIView *)view{
    for(UIWindow * tmpWin in [[UIApplication sharedApplication] windows]){
        [tmpWin endEditing:NO];
    }
    [self customShowInView:view];
}
+ (void)load{
    swizzleAllActionSheet();
}
@end

void swizzleAllActionSheet(){
    Class c = [UIActionSheet class];
    SEL origSEL = @selector(showInView:);
    SEL newSEL = @selector(customShowInView:);
    Method origMethod = class_getInstanceMethod(c, origSEL);
    Method newMethod = class_getInstanceMethod(c, newSEL);
    method_exchangeImplementations(origMethod, newMethod);
}