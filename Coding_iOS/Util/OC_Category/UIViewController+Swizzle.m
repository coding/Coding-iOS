//
//  UIViewController+Swizzle.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import "ObjcRuntime.h"
#import "RDVTabBarController.h"


@implementation UIViewController (Swizzle)
- (void)customViewDidLoad{
//    返回按钮
    if (!self.navigationItem.leftBarButtonItem
        && self.navigationController.viewControllers.count > 1
        && !kHigher_iOS_6_1) {//设置iOS_7以下版本的返回按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self backButton]];
    }
    [self customViewDidLoad];
}

- (void)customViewWillDisappear:(BOOL)animated{
//    返回按钮
    if (!self.navigationItem.backBarButtonItem
        && self.navigationController.viewControllers.count > 1
        && kHigher_iOS_6_1) {//设置iOS_7及以上版本的返回按钮(backBarButtonItem的图片不能设置；如果用leftBarButtonItem属性，则iOS7自带的滑动返回功能会失效)
        self.navigationItem.backBarButtonItem = [self backButton_higherOS];
    }
    [self customViewWillDisappear:animated];
}

- (void)customviewWillAppear:(BOOL)animated{
    if ([self isKindOfClass:[UINavigationController class]]) {
//        do nothing
    }else
    if ([NSStringFromClass([self class]) rangeOfString:@"_RootViewController"].location != NSNotFound) {
        [self.rdv_tabBarController setTabBarHidden:NO animated:NO];
    }else{
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
    [self customviewWillAppear:animated];
}


#pragma mark BackBtn M
- (UIBarButtonItem *)backButton_higherOS{
    NSDictionary*textAttributes;
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    temporaryBarButtonItem.target = self;
    if ([temporaryBarButtonItem respondsToSelector:@selector(setTitleTextAttributes:forState:)]){
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:kBackButtonFontSize],
                           NSForegroundColorAttributeName: [UIColor whiteColor],
                           };
        
        [[UIBarButtonItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    }
    temporaryBarButtonItem.action = @selector(goBack_Swizzle);
    return temporaryBarButtonItem;
}

-(UIButton*)backButton{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* buttonImage = [UIImage imageNamed:@"backBtn_Nav"];
    button.frame = CGRectMake(0, 0, 55, 30);
    [button setImage:buttonImage forState:UIControlStateNormal];

    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:kBackButtonFontSize];
    [button.titleLabel setMinimumScaleFactor:0.5];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    
    
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    [button addTarget:self action:@selector(goBack_Swizzle) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
- (void)goBack_Swizzle
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

void swizzleAllViewController()
{
    Swizzle([UIViewController class], @selector(viewDidLoad), @selector(customViewDidLoad));
    Swizzle([UIViewController class], @selector(viewWillDisappear:), @selector(customViewWillDisappear:));
    Swizzle([UIViewController class], @selector(viewWillAppear:), @selector(customviewWillAppear:));
}