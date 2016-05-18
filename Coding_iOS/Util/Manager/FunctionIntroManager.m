//
//  FunctionIntroManager.m
//  Coding_iOS
//
//  Created by Ease on 15/8/6.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kIntroPageKey @"intro_page_version"
#define kIntroPageNum 2

#import "FunctionIntroManager.h"
#import "EAIntroView.h"
#import "SMPageControl.h"
#import <NYXImagesKit/NYXImagesKit.h>


@implementation FunctionIntroManager
#pragma mark EAIntroPage

+ (void)showIntroPage{
    if (![self needToShowIntro]) {
        return;
    }
    NSMutableArray *pages = [NSMutableArray new];
    for (int index = 0; index < kIntroPageNum; index ++) {
        EAIntroPage *page = [self p_pageWithIndex:index];
        [pages addObject:page];
    }
    if (pages.count <= 0) {
        return;
    }
    EAIntroView *introView = [[EAIntroView alloc] initWithFrame:kScreen_Bounds andPages:pages];
    introView.backgroundColor = [UIColor whiteColor];
    introView.swipeToExit = YES;
    introView.scrollView.bounces = YES;
    
//    introView.skipButton = [self p_skipButton];
//    introView.skipButtonY = 20.f + CGRectGetHeight(introView.skipButton.frame);
//    introView.skipButtonAlignment = EAViewAlignmentCenter;
    
    if (pages.count <= 1) {
        introView.pageControl.hidden = YES;
    }else{
        introView.pageControl = [self p_pageControl];
        introView.pageControlY = 10.f + CGRectGetHeight(introView.pageControl.frame);
    }
    [introView showFullscreen];
    //
    [self markHasBeenShowed];
}

+ (BOOL)needToShowIntro{
//    return YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preVersion = [defaults stringForKey:kIntroPageKey];
    BOOL needToShow = ![preVersion isEqualToString:kVersion_Coding];
    if (![NSDate isDuringMidAutumn]) {//中秋节期间才显示
        needToShow = NO;
    }
    return needToShow;
}

+ (void)markHasBeenShowed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:kVersion_Coding forKey:kIntroPageKey];
    [defaults synchronize];
}

#pragma mark private M
+ (UIPageControl *)p_pageControl{
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_dot_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_dot_selected"];
    
    if (!kDevice_Is_iPhone6 && !kDevice_Is_iPhone6Plus) {
        CGFloat desginWidth = 375.0;//iPhone6 的设计尺寸
        CGFloat scaleFactor = kScreen_Width/desginWidth;
        pageIndicatorImage = [pageIndicatorImage scaleByFactor:scaleFactor];
        currentPageIndicatorImage = [currentPageIndicatorImage scaleByFactor:scaleFactor];
    }
    
    SMPageControl *pageControl = [SMPageControl new];
    pageControl.pageIndicatorImage = pageIndicatorImage;
    pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
    [pageControl sizeToFit];
    return (UIPageControl *)pageControl;
}

+ (UIButton *)p_skipButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width*0.7, 60)];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"0x1b9d59"] forState:UIControlStateHighlighted];
    return button;
}

+ (EAIntroPage *)p_pageWithIndex:(NSInteger)index{
    NSString *imageName = [NSString stringWithFormat:@"intro_page%ld", (long)index];
    if (kDevice_Is_iPhone6Plus) {
        imageName = [imageName stringByAppendingString:@"_ip6+"];
    }else if (kDevice_Is_iPhone6){
        imageName = [imageName stringByAppendingString:@"_ip6"];
    }else if (kDevice_Is_iPhone5){
        imageName = [imageName stringByAppendingString:@"_ip5"];
    }else{
        imageName = [imageName stringByAppendingString:@"_ip4"];
    }
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView;
    if (!image) {
        imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor randomColor];
    }else{
        imageView = [[UIImageView alloc] initWithImage:image];
    }
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    EAIntroPage *page = [EAIntroPage pageWithCustomView:imageView];
    return page;
}

@end
