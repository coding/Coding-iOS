//
//  BaseNavigationController.m
//  Coding_iOS
//
//  Created by Ease on 15/2/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()
@property (strong, nonatomic) UIView *navLineV;
@end

@implementation BaseNavigationController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setupBorderInView:self.navigationBar];
}

- (void)setupBorderInView:(UIView *)view{
    if ([view isKindOfClass:[UIImageView class]]
        && view.frame.size.height <= 1) {
        view.hidden = YES;
        
        if (!_navLineV) {
            _navLineV = ({
                UIView *lineV = [UIView new];
                lineV.backgroundColor = kColorDDD;
                [view.superview addSubview:lineV];
                [lineV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.right.bottom.equalTo(view.superview);
                    make.height.mas_equalTo(1.0/ [UIScreen mainScreen].scale);
                }];
                lineV;
            });
        }
    }
    for (UIView *subView in view.subviews) {
        [self setupBorderInView:subView];
    }
}

- (BOOL)shouldAutorotate{
    return [self.visibleViewController shouldAutorotate];

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (![self.visibleViewController isKindOfClass:[UIAlertController class]]) {//iOS9 UIWebRotatingAlertController
        return [self.visibleViewController supportedInterfaceOrientations];
    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
