//
//  EasePageViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/5/8.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EasePageViewController.h"
#import "RKSwipeBetweenViewControllers.h"

@interface EasePageViewController ()

@end

@implementation EasePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark lifeCycle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([self.parentViewController isKindOfClass:[RKSwipeBetweenViewControllers class]]) {
        RKSwipeBetweenViewControllers *swipeVC = (RKSwipeBetweenViewControllers *)self.parentViewController;
        [[swipeVC curViewController] viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([self.parentViewController isKindOfClass:[RKSwipeBetweenViewControllers class]]) {
        RKSwipeBetweenViewControllers *swipeVC = (RKSwipeBetweenViewControllers *)self.parentViewController;
        [[swipeVC curViewController] viewWillDisappear:animated];
    }
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
