//
//  EAIntroView.h
//
//  Copyright (c) 2013-2015 Evgeny Aleksandrov. License: MIT.

#import <UIKit/UIKit.h>
#import "EARestrictedScrollView.h"
#import "EAIntroPage.h"

#define EA_EMPTY_PROPERTY 9999.f

enum EAIntroViewTags {
    kTitleLabelTag = 1,
    kDescLabelTag,
    kTitleImageViewTag
};

typedef NS_ENUM(NSUInteger, EAViewAlignment) {
    EAViewAlignmentLeft,
    EAViewAlignmentCenter,
    EAViewAlignmentRight,
};

@class EAIntroView;

@protocol EAIntroDelegate<NSObject>
@optional
- (void)introDidFinish:(EAIntroView *)introView;
- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex;
- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex;
- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex;
@end

@interface EAIntroView : UIView <UIScrollViewDelegate>

@property (nonatomic, weak) id<EAIntroDelegate> delegate;

@property (nonatomic, assign) BOOL swipeToExit;
@property (nonatomic, assign) BOOL tapToNext;
@property (nonatomic, assign) BOOL hideOffscreenPages;
@property (nonatomic, assign) BOOL easeOutCrossDisolves;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, assign) CGFloat motionEffectsRelativeValue;

// Title View (Y position - from top of the screen)
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, assign) CGFloat titleViewY;

// Background image
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, assign) UIViewContentMode bgViewContentMode;

// Page Control (Y position - from bottom of the screen)
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) CGFloat pageControlY;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign, readonly) NSUInteger visiblePageIndex;

// Skip button (Y position - from bottom of the screen)
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, assign) CGFloat skipButtonY;
@property (nonatomic, assign) CGFloat skipButtonSideMargin;
@property (nonatomic, assign) EAViewAlignment skipButtonAlignment;
@property (nonatomic, assign) BOOL showSkipButtonOnlyOnLastPage;

@property (nonatomic, strong) EARestrictedScrollView *scrollView;
@property (nonatomic, assign) BOOL scrollingEnabled;
@property (nonatomic, strong) NSArray *pages;

- (id)initWithFrame:(CGRect)frame andPages:(NSArray *)pagesArray;

- (void)showFullscreen;
- (void)showFullscreenWithAnimateDuration:(CGFloat)duration;
- (void)showFullscreenWithAnimateDuration:(CGFloat)duration andInitialPageIndex:(NSUInteger)initialPageIndex;
- (void)showInView:(UIView *)view;
- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration;
- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration withInitialPageIndex:(NSUInteger)initialPageIndex;

- (void)hideWithFadeOutDuration:(CGFloat)duration;

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex;
- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated;

- (void)limitScrollingToPage:(NSUInteger)lastPageIndex;

@end
