//
//  RootTabViewController.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "RootTabViewController.h"
#import "Project_RootViewController.h"
#import "MyTask_RootViewController.h"
#import "Tweet_RootViewController.h"
#import "Me_RootViewController.h"
#import "Message_RootViewController.h"
#import "RDVTabBarItem.h"
#import "UnReadManager.h"
#import "BaseNavigationController.h"

@interface RootTabViewController ()

@end

@implementation RootTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewControllers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Private_M
- (void)setupViewControllers {
    Project_RootViewController *project = [[Project_RootViewController alloc] init];
    UINavigationController *nav_project = [[BaseNavigationController alloc] initWithRootViewController:project];
    
    MyTask_RootViewController *mytask = [[MyTask_RootViewController alloc] init];
    UINavigationController *nav_mytask = [[BaseNavigationController alloc] initWithRootViewController:mytask];
    
    Tweet_RootViewController *tweet = [[Tweet_RootViewController alloc] init];
    UINavigationController *nav_tweet = [[BaseNavigationController alloc] initWithRootViewController:tweet];
    
    Message_RootViewController *message = [[Message_RootViewController alloc] init];
    UINavigationController *nav_message = [[BaseNavigationController alloc] initWithRootViewController:message];
    
    Me_RootViewController *me = [[Me_RootViewController alloc] init];
    UINavigationController *nav_me = [[BaseNavigationController alloc] initWithRootViewController:me];
    
    [self setViewControllers:@[nav_project, nav_mytask, nav_tweet, nav_message, nav_me]];
    
    [self customizeTabBarForController];
    self.delegate = self;
}

- (void)customizeTabBarForController {
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_background"];
    NSArray *tabBarItemImages = @[@"project", @"task", @"tweet", @"privatemessage", @"me"];
    NSArray *tabBarItemTitles = @[@"我的项目", @"我的任务", @"冒泡", @"消息", @"我"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setBackgroundSelectedImage:backgroundImage withUnselectedImage:backgroundImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        [item setTitle:[tabBarItemTitles objectAtIndex:index]];
        index++;
    }
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (tabBarController.selectedViewController == viewController) {        
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)viewController;
            if (nav.topViewController == nav.viewControllers[0]) {
                BaseViewController *rootVC = (BaseViewController *)nav.topViewController;
#pragma clang diagnostic ignored "-Warc-performSelector"
                [rootVC performSelector:@selector(tabBarItemClicked)];
            }
        }
    }
    return YES;
}
@end
