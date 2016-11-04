//
//  FunctionIntroManager.m
//  Coding_iOS
//
//  Created by Ease on 15/8/6.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kIntroPageKey @"intro_page_version"
#define kIntroPageNum 3

#import "FunctionIntroManager.h"
#import "EAIntroView.h"
#import "SMPageControl.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface FunctionIntroManager ()<EAIntroDelegate>
@property (strong, nonatomic) EAIntroView *introView;
@end

@implementation FunctionIntroManager
#pragma mark EAIntroPage
+ (void)showIntroPage{
    if ([self needToShowIntro]) {
        FunctionIntroManager *manager = [FunctionIntroManager shareManager];
        [manager.introView showFullscreen];
        [self markHasBeenShowed];
    }
}

+ (BOOL)needToShowIntro{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *preVersion = [defaults stringForKey:kIntroPageKey];
    BOOL needToShow = ![preVersion isEqualToString:kVersionBuild_Coding];
    needToShow = NO;//不显示了
    return needToShow;
}

+ (void)markHasBeenShowed{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:kVersionBuild_Coding forKey:kIntroPageKey];
    [defaults synchronize];
}

#pragma mark private M

+ (instancetype)shareManager{
    static FunctionIntroManager *shared_manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        shared_manager = [self new];
    });
    return shared_manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSMutableArray *pages = [NSMutableArray new];
        for (int index = 0; index < kIntroPageNum; index ++) {
            EAIntroPage *page = [self p_pageWithIndex:index];
            [pages addObject:page];
        }
        _introView = [[EAIntroView alloc] initWithFrame:kScreen_Bounds andPages:pages];
        _introView.backgroundColor = [UIColor whiteColor];
        _introView.swipeToExit = YES;
        _introView.scrollView.bounces = YES;
        _introView.skipButton = nil;
        _introView.delegate = self;
        if (pages.count <= 1) {
            _introView.pageControl.hidden = YES;
        }else{
            _introView.pageControl = [self p_pageControl];
            _introView.pageControlY = 30.f + CGRectGetHeight(_introView.pageControl.frame);
        }
    }
    return self;
}

- (UIPageControl *)p_pageControl{
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_page_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_page_selected"];
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

- (UIButton *)p_skipButton{
    UIButton *button = [UIButton new];
    [button addTarget:self action:@selector(dismissIntroView) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.backgroundColor = kColorNavBG;
    [button setTitleColor:kColor999 forState:UIControlStateNormal];
    [button setTitleColor:kColorDDD forState:UIControlStateHighlighted];
    [button setTitle:@"跳过" forState:UIControlStateNormal];
    [button doBorderWidth:0 color:nil cornerRadius:15.0];
    return button;
}

- (UIButton *)p_useImmediatelyButton{
    UIButton *button = [UIButton new];
    [button addTarget:self action:@selector(dismissIntroView) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    button.backgroundColor = kColorBrandGreen;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightTextColor] forState:UIControlStateHighlighted];
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    [button doBorderWidth:0 color:nil cornerRadius:4.0];
    return button;
}

- (void)dismissIntroView{
    [self.introView hideWithFadeOutDuration:0.3];
}

- (EAIntroPage *)p_pageWithIndex:(NSInteger)index{
    NSString *imageName = [NSString stringWithFormat:@"intro_page%ld", (long)index];
    imageName = [imageName stringByAppendingString:(kDevice_Is_iPhone6Plus? @"_ip6+":
                                                    kDevice_Is_iPhone6? @"_ip6":
                                                    kDevice_Is_iPhone5? @"_ip5":
                                                    @"_ip4")];
    UIImageView *imageView = [UIImageView new];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.image = [UIImage imageNamed:imageName];
    imageView.backgroundColor = imageView.image? [UIColor clearColor]: [UIColor randomColor];
    if (index < kIntroPageNum - 1) {
        UIButton *button = [self p_skipButton];
        [imageView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 30));
            make.top.equalTo(imageView).offset(30);
            make.right.equalTo(imageView).offset(-20);
        }];
    }else{
        UIButton *button = [self p_useImmediatelyButton];
        [imageView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 44));
            make.centerX.equalTo(imageView);
            make.bottom.equalTo(imageView).offset(kDevice_Is_iPhone4? -30: -40);
        }];
    }
    EAIntroPage *page = [EAIntroPage pageWithCustomView:imageView];
    return page;
}

#pragma mark EAIntroDelegate
- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex{
    introView.pageControl.hidden = (pageIndex >= kIntroPageNum - 2);
}
- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex{
    introView.pageControl.hidden = (pageIndex == kIntroPageNum - 1);
}
- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex{
    introView.pageControl.hidden = (pageIndex == kIntroPageNum - 1);
}

@end
