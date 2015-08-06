//
//  EAIntroView.m
//
//  Copyright (c) 2013-2015 Evgeny Aleksandrov. License: MIT.

#import "EAIntroView.h"

@interface EAIntroView()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *pageBgBack;
@property (nonatomic, strong) UIImageView *pageBgFront;

@property (nonatomic, strong) NSMutableArray *footerConstraints;
@property (nonatomic, strong) NSMutableArray *titleViewConstraints;

@end

@interface EAIntroPage()

@property (nonatomic, strong, readwrite) UIView *pageView;

@end


@implementation EAIntroView

@synthesize pageControl = _pageControl;
@synthesize skipButton = _skipButton;

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self applyDefaultsToSelfDuringInitializationWithFrame:frame pages:nil];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self applyDefaultsToSelfDuringInitializationWithFrame:self.frame pages:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andPages:(NSArray *)pagesArray {
    self = [super initWithFrame:frame];
    if (self) {
        [self applyDefaultsToSelfDuringInitializationWithFrame:self.frame pages:pagesArray];
    }
    return self;
}

#pragma mark - Private

- (void)applyDefaultsToSelfDuringInitializationWithFrame:(CGRect)frame pages:(NSArray *)pagesArray {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.swipeToExit = YES;
    self.easeOutCrossDisolves = YES;
    self.hideOffscreenPages = YES;
    self.bgViewContentMode = UIViewContentModeScaleAspectFill;
    self.motionEffectsRelativeValue = 40.f;
    self.backgroundColor = [UIColor blackColor];
    _scrollingEnabled = YES;
    _titleViewY = 20.f;
    _pageControlY = 50.f;
    _skipButtonY = EA_EMPTY_PROPERTY;
    _skipButtonSideMargin = 10.f;
    _skipButtonAlignment = EAViewAlignmentRight;
    
    
    [self buildBackgroundImage];
    
    self.pages = [pagesArray copy];
    
    [self buildFooterView];
    
    // Add observer for device orientation:
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)applyDefaultsToBackgroundImageView:(UIImageView *)backgroundImageView {
    backgroundImageView.backgroundColor = [UIColor clearColor];
    backgroundImageView.contentMode = self.bgViewContentMode;
    backgroundImageView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)makePanelVisibleAtIndex:(NSUInteger)panelIndex{
    [UIView animateWithDuration:0.3 animations:^{
        for (int idx = 0; idx < _pages.count; idx++) {
            if (idx == panelIndex) {
                [[self viewForPageIndex:idx] setAlpha:[self alphaForPageIndex:idx]];
            } else {
                if(!self.hideOffscreenPages) {
                    [[self viewForPageIndex:idx] setAlpha:0];
                }
            }
        }
    }];
}

- (EAIntroPage *)pageForIndex:(NSUInteger)idx {
    if(idx >= _pages.count) {
        return nil;
    }
    
    return (EAIntroPage *)_pages[idx];
}

- (CGFloat)alphaForPageIndex:(NSUInteger)idx {
    if(![self pageForIndex:idx]) {
        return 1.f;
    }
    
    return [self pageForIndex:idx].alpha;
}

- (BOOL)showTitleViewForPage:(NSUInteger)idx {
    if(![self pageForIndex:idx]) {
        return NO;
    }
    
    return [self pageForIndex:idx].showTitleView;
}

- (UIView *)viewForPageIndex:(NSUInteger)idx {
    return [self pageForIndex:idx].pageView;
}

- (UIImage *)bgImageForPage:(NSUInteger)idx {
    return [self pageForIndex:idx].bgImage;
}

- (UIColor *)bgColorForPage:(NSUInteger)idx {
    return [self pageForIndex:idx].bgColor;
}

- (void)showPanelAtPageControl {
    [self makePanelVisibleAtIndex:self.currentPageIndex];
    
    [self setCurrentPageIndex:self.pageControl.currentPage animated:YES];
}

- (void)checkIndexForScrollView:(EARestrictedScrollView *)scrollView {
    NSUInteger newPageIndex = (scrollView.contentOffset.x + scrollView.bounds.size.width/2)/self.scrollView.frame.size.width;
    [self notifyDelegateWithPreviousPage:self.currentPageIndex andCurrentPage:newPageIndex];
    _currentPageIndex = newPageIndex;
    
    if (self.currentPageIndex == (_pages.count)) {
        
        //if run here, it means you can't  call _pages[self.currentPageIndex],
        //to be safe, set to the biggest index
        _currentPageIndex = _pages.count - 1;
        
        [self finishIntroductionAndRemoveSelf];
    }
}

- (void)finishIntroductionAndRemoveSelf {
	if ([(id)self.delegate respondsToSelector:@selector(introDidFinish:)]) {
		[self.delegate introDidFinish:self];
	}
    
    // Remove observer for rotation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    //prevent last page flicker on disappearing
    self.alpha = 0;
    
    //Calling removeFromSuperview from scrollViewDidEndDecelerating: method leads to crash on iOS versions < 7.0.
    //removeFromSuperview should be called after a delay
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)0);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self removeFromSuperview];
    });
}

- (void)skipIntroduction {
    [self hideWithFadeOutDuration:0.5];
}

- (void)notifyDelegateWithPreviousPage:(NSUInteger)previousPageIndex andCurrentPage:(NSUInteger)currentPageIndex {
    if(currentPageIndex!=_currentPageIndex && currentPageIndex < _pages.count) {
        EAIntroPage* previousPage = _pages[previousPageIndex];
        EAIntroPage* currentPage = _pages[currentPageIndex];
        if(previousPage.onPageDidDisappear) previousPage.onPageDidDisappear();
        if(currentPage.onPageDidAppear) currentPage.onPageDidAppear();
        
        if ([(id)self.delegate respondsToSelector:@selector(intro:pageAppeared:withIndex:)]) {
            [self.delegate intro:self pageAppeared:_pages[currentPageIndex] withIndex:currentPageIndex];
        }
    }
}

#pragma mark - Properties

- (EARestrictedScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[EARestrictedScrollView alloc] initWithFrame:self.bounds];
        _scrollView.accessibilityIdentifier = @"intro_scroll";
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceHorizontal = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return _scrollView;
}

- (NSUInteger)visiblePageIndex {
    return (NSUInteger) ((self.scrollView.contentOffset.x + self.scrollView.bounds.size.width/2) / self.scrollView.frame.size.width);
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self applyDefaultsToBackgroundImageView:_bgImageView];
    }
    return _bgImageView;
}

- (UIImageView *)pageBgBack {
    if (!_pageBgBack) {
        _pageBgBack = [[UIImageView alloc] initWithFrame:self.bounds];
        [self applyDefaultsToBackgroundImageView:_pageBgBack];
        _pageBgBack.alpha = 0;
    }
    return _pageBgBack;
}

- (UIImageView *)pageBgFront {
    if (!_pageBgFront) {
        _pageBgFront = [[UIImageView alloc] initWithFrame:self.bounds];
        [self applyDefaultsToBackgroundImageView:_pageBgFront];
        _pageBgFront.alpha = 0;
    }
    return _pageBgFront;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        [self applyDefaultsToPageControl];
    }
    return _pageControl;
}

- (void)applyDefaultsToPageControl {
    _pageControl.defersCurrentPageDisplay = YES;
    _pageControl.numberOfPages = _pages.count;
    _pageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [_pageControl addTarget:self action:@selector(showPanelAtPageControl) forControlEvents:UIControlEventValueChanged];
}

- (UIButton *)skipButton {
    if (!_skipButton) {
        _skipButton = [[UIButton alloc] init];
        [_skipButton setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
        [self applyDefaultsToSkipButton];
    }
    return _skipButton;
}

- (void)applyDefaultsToSkipButton {
    _skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_skipButton addTarget:self action:@selector(skipIntroduction) forControlEvents:UIControlEventTouchUpInside];
}

- (NSMutableArray *)footerConstraints {
    if (!_footerConstraints) {
        _footerConstraints = [NSMutableArray array];
    }
    return _footerConstraints;
}

- (NSMutableArray *)titleViewConstraints {
    if (!_titleViewConstraints) {
        _titleViewConstraints = [NSMutableArray array];
    }
    return _titleViewConstraints;
}

#pragma mark - UI building

- (void)buildBackgroundImage {
    [self addSubview:self.bgImageView];
    [self addSubview:self.pageBgBack];
    [self addSubview:self.pageBgFront];
    
    if (self.useMotionEffects) {
        [self addMotionEffectsOnBg];
    }
}

- (void)buildScrollView {
    CGFloat contentXIndex = 0;
    for (NSUInteger idx = 0; idx < _pages.count; idx++) {
        EAIntroPage *page = _pages[idx];
        page.pageView = [self viewForPage:page atXIndex:contentXIndex];
        contentXIndex += self.scrollView.frame.size.width;
        [self.scrollView addSubview:page.pageView];
        if(page.onPageDidLoad) page.onPageDidLoad();
    }
    
    [self makePanelVisibleAtIndex:0];
    
    if (self.swipeToExit) {
        [self appendCloseViewAtXIndex:&contentXIndex];
    }
    
    [self insertSubview:self.scrollView aboveSubview:self.pageBgFront];
    self.scrollView.contentSize = CGSizeMake(contentXIndex, self.scrollView.frame.size.height);
    
    self.pageBgBack.alpha = 0;
    self.pageBgBack.image = [self bgImageForPage:1];
    self.pageBgBack.backgroundColor = [self bgColorForPage:1];
    self.pageBgFront.alpha = [self alphaForPageIndex:0];
    self.pageBgFront.image = [self bgImageForPage:0];
    self.pageBgFront.backgroundColor = [self bgColorForPage:0];
}

- (UIView *)viewForPage:(EAIntroPage *)page atXIndex:(CGFloat)xIndex {
    UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(xIndex, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    
    pageView.accessibilityLabel = [NSString stringWithFormat:@"intro_page_%lu",(unsigned long)[self.pages indexOfObject:page]];
    
    if(page.customView) {
        [pageView addSubview:page.customView];
        
        NSMutableArray *constraints = @[].mutableCopy;
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[customView]-0-|" options:0 metrics:nil views:@{@"customView": page.customView}]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[customView]-0-|" options:0 metrics:nil views:@{@"customView": page.customView}]];
        
        [pageView addConstraints:constraints];
        
        return pageView;
    }
    
    UIButton *tapToNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    tapToNextButton.frame = pageView.bounds;
    tapToNextButton.translatesAutoresizingMaskIntoConstraints = NO;
    [tapToNextButton addTarget:self action:@selector(goToNext:) forControlEvents:UIControlEventTouchUpInside];
    [pageView addSubview:tapToNextButton];
    
    NSMutableArray *constraints = @[].mutableCopy;
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tapToNextButton]-0-|" options:0 metrics:nil views:@{@"tapToNextButton": tapToNextButton}]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tapToNextButton]-0-|" options:0 metrics:nil views:@{@"tapToNextButton": tapToNextButton}]];
    [pageView addConstraints:constraints];
    
    UIView *titleImageView;
    if(page.titleIconView) {
        titleImageView = page.titleIconView;
        titleImageView.tag = kTitleImageViewTag;
        titleImageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [pageView addSubview:titleImageView];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-topSpace@250-[titleImageView(imageHeight)]" options:NSLayoutFormatAlignAllTop metrics:@{@"imageHeight" : @(page.titleIconView.frame.size.height), @"topSpace" : @(page.titleIconPositionY)} views:@{@"titleImageView" : titleImageView}]];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[titleImageView(imageWidth)]" options:0 metrics:@{@"imageWidth" : @(page.titleIconView.frame.size.width)} views:@{@"titleImageView" : titleImageView}]];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[superview]-(<=1)-[titleImageView]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"superview" : pageView, @"titleImageView" : titleImageView}]];
    }
    
    UILabel *titleLabel;
    if(page.title.length) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.text = page.title;
        titleLabel.font = page.titleFont;
        titleLabel.textColor = page.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.tag = kTitleLabelTag;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [pageView addSubview:titleLabel];
        NSLayoutConstraint *weakConstraint = [NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:titleLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:page.titlePositionY];
        weakConstraint.priority = UILayoutPriorityDefaultLow;
        [pageView addConstraint:weakConstraint];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[titleLabel]-10-|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"titleLabel" : titleLabel}]];
    }
    
    UITextView *descLabel;
    if(page.desc.length) {
        descLabel = [[UITextView alloc] init];
        descLabel.text = page.desc;
        descLabel.scrollEnabled = NO;
        descLabel.font = page.descFont;
        descLabel.textColor = page.descColor;
        descLabel.backgroundColor = [UIColor clearColor];
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.userInteractionEnabled = NO;
        descLabel.tag = kDescLabelTag;
        descLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [pageView addSubview:descLabel];
        NSLayoutConstraint *weakConstraint = [NSLayoutConstraint constraintWithItem:pageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:descLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:page.descPositionY];
        weakConstraint.priority = UILayoutPriorityDefaultLow;
        [pageView addConstraint:weakConstraint];
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descLabel]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"descLabel" : descLabel}]];
    }
    
    // Constraints for handling landscape orientation
    if(titleImageView && titleLabel && descLabel) {
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[titleImageView]->=0-[titleLabel]->=0-[descLabel]" options:0 metrics:nil views:@{@"titleImageView" : titleImageView, @"titleLabel" : titleLabel, @"descLabel" : descLabel}]];
    } else if(!titleImageView && titleLabel && descLabel) {
        [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=0-[titleLabel]->=0-[descLabel]" options:0 metrics:nil views:@{@"titleLabel" : titleLabel, @"descLabel" : descLabel}]];
    }
    
    if(page.subviews) {
        for (UIView *subV in page.subviews) {
            [pageView addSubview:subV];
        }
    }
    
    if(page.alpha < 1.f || !page.bgImage) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    pageView.alpha = page.alpha;
    
    return pageView;
}

- (void)appendCloseViewAtXIndex:(CGFloat*)xIndex {
    UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake(*xIndex, 0, self.bounds.size.width, self.bounds.size.height)];
    closeView.tag = 124;
    [self.scrollView addSubview:closeView];
    
    *xIndex += self.scrollView.frame.size.width;
}

- (void)removeCloseViewAtXIndex:(CGFloat*)xIndex {
    UIView *closeView = [self.scrollView viewWithTag:124];
    if(closeView) {
        [closeView removeFromSuperview];
    }
    
    *xIndex -= self.scrollView.frame.size.width;
}

- (void)buildTitleView {
    if (!self.titleView.superview) {
        [self addSubview:self.titleView];
    }
    
    if (self.titleViewConstraints.count) {
        [self removeConstraints:self.titleViewConstraints];
        [self.titleViewConstraints removeAllObjects];
    }
    
    NSDictionary *views = @{@"titleView" : self.titleView};
    NSDictionary *metrics = @{@"titleViewTopPadding" : @(self.titleViewY), @"titleViewHeight" : @(self.titleView.frame.size.height), @"titleViewWidth" : @(self.titleView.frame.size.width)};
    
    [self.titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-titleViewTopPadding@250-[titleView(titleViewHeight)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    [self.titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[titleView(titleViewWidth)]" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
    [self.titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:self.titleViewConstraints];
    
    [self.titleView setNeedsUpdateConstraints];
}

- (void)buildFooterView {
    if (!self.pageControl.superview) {
        [self insertSubview:self.pageControl aboveSubview:self.scrollView];
    }
    
    if (!self.skipButton.superview) {
        [self insertSubview:self.skipButton aboveSubview:self.scrollView];
    }
    
    [self.pageControl.superview bringSubviewToFront:self.pageControl];
    [self.skipButton.superview bringSubviewToFront:self.skipButton];
    
    if (self.footerConstraints.count) {
        [self removeConstraints:self.footerConstraints];
        [self.footerConstraints removeAllObjects];
    }
    
    NSDictionary *views = @{@"pageControl" : self.pageControl, @"skipButton" : self.skipButton};
    NSDictionary *metrics = @{@"pageControlBottomPadding" : @(self.pageControlY - self.pageControl.frame.size.height), @"pageControlHeight" : @(self.pageControl.frame.size.height), @"skipButtonBottomPadding" : @(self.skipButtonY - self.skipButton.frame.size.height), @"skipButtonSideMargin" : @(self.skipButtonSideMargin), @"skipButtonWidth" : @(self.skipButton.frame.size.width), @"skipButtonHeight" : @(self.skipButton.frame.size.height)};
    
    [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[pageControl]-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
    [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pageControl(pageControlHeight)]-pageControlBottomPadding@250-|" options:NSLayoutFormatAlignAllBottom metrics:metrics views:views]];
    
    if (self.skipButton && !self.skipButton.hidden) {
        if(self.skipButtonAlignment == EAViewAlignmentCenter) {
            [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[skipButton(skipButtonWidth)]" options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
            [self.footerConstraints addObject:[NSLayoutConstraint constraintWithItem:self.skipButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        } else if(self.skipButtonAlignment == EAViewAlignmentLeft) {
            [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-skipButtonSideMargin-[skipButton]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        } else if(self.skipButtonAlignment == EAViewAlignmentRight) {
            [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[skipButton]-skipButtonSideMargin-|" options:NSLayoutFormatAlignAllRight metrics:metrics views:views]];
        }
        
        if(self.skipButtonY == EA_EMPTY_PROPERTY) {
            [self.footerConstraints addObject:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.skipButton attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        } else {
            [self.footerConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[skipButton(skipButtonHeight)]-skipButtonBottomPadding-|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:views]];
        }
    }
    
    [self addConstraints:self.footerConstraints];
    
    [self.pageControl setNeedsUpdateConstraints];
    [self.skipButton setNeedsUpdateConstraints];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillBeginDragging:(EARestrictedScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(intro:pageStartScrolling:withIndex:)] && self.currentPageIndex < [self.pages count]) {
        [self.delegate intro:self pageStartScrolling:_pages[self.currentPageIndex] withIndex:self.currentPageIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(EARestrictedScrollView *)scrollView {
    [self checkIndexForScrollView:scrollView];
    if ([self.delegate respondsToSelector:@selector(intro:pageEndScrolling:withIndex:)] && self.currentPageIndex < [self.pages count]) {
        [self.delegate intro:self pageEndScrolling:_pages[self.currentPageIndex] withIndex:self.currentPageIndex];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(EARestrictedScrollView *)scrollView {
    [self checkIndexForScrollView:scrollView];
}

- (void)scrollViewDidScroll:(EARestrictedScrollView *)scrollView {
    if(!self.scrollingEnabled) {
        return;
    }
    
    CGFloat offset = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    NSUInteger page = (NSUInteger)(offset);
    
    if (page == (_pages.count - 1) && self.swipeToExit) {
        self.alpha = ((self.scrollView.frame.size.width*_pages.count)-self.scrollView.contentOffset.x)/self.scrollView.frame.size.width;
    } else {
        if([self pageForIndex:page]) {
            self.alpha = 1.f;
        }
        
        [self crossDissolveForOffset:offset];
    }
    
    if (self.visiblePageIndex < _pages.count) {
        self.pageControl.currentPage = self.visiblePageIndex;
        
        [self makePanelVisibleAtIndex:self.visiblePageIndex];
    }
}

CGFloat easeOutValue(CGFloat value) {
    CGFloat inverse = value - 1.f;
    return (CGFloat) (1.f + inverse * inverse * inverse);
}

- (void)crossDissolveForOffset:(CGFloat)offset {
    NSUInteger page = (NSUInteger)(offset);
    CGFloat alphaValue = offset - page;
    
    if (alphaValue < 0 && self.visiblePageIndex == 0){
        self.pageBgBack.image = nil;
        return;
    }
    
    self.pageBgFront.alpha = [self alphaForPageIndex:page];
    self.pageBgFront.image = [self bgImageForPage:page];
    self.pageBgFront.backgroundColor = [self bgColorForPage:page];
    self.pageBgBack.alpha = 0;
    self.pageBgBack.image = [self bgImageForPage:page+1];
    self.pageBgBack.backgroundColor = [self bgColorForPage:page+1];
    
    CGFloat backLayerAlpha = alphaValue;
    CGFloat frontLayerAlpha = (1 - alphaValue);
    
    if (self.easeOutCrossDisolves) {
        backLayerAlpha = easeOutValue(backLayerAlpha);
        frontLayerAlpha = easeOutValue(frontLayerAlpha);
    }
    
    self.pageBgBack.alpha = MIN(backLayerAlpha,[self alphaForPageIndex:page+1]);
    self.pageBgFront.alpha = MIN(frontLayerAlpha,[self alphaForPageIndex:page]);
    
    if(self.titleView) {
        if([self showTitleViewForPage:page] && [self showTitleViewForPage:page+1]) {
            [self.titleView setAlpha:1.0];
        } else if(![self showTitleViewForPage:page] && ![self showTitleViewForPage:page+1]) {
            [self.titleView setAlpha:0.0];
        } else if([self showTitleViewForPage:page]) {
            [self.titleView setAlpha:(1 - alphaValue)];
        } else {
            [self.titleView setAlpha:alphaValue];
        }
    }
    
    if(self.skipButton && self.showSkipButtonOnlyOnLastPage) {
        if(page < (long)[self.pages count] - 2) {
            [self.skipButton setAlpha:0.0];
        } else if(page == [self.pages count] - 1) {
            [self.skipButton setAlpha:(1 - alphaValue)];
        } else {
            [self.skipButton setAlpha:alphaValue];
        }
    }
}

#pragma mark - Notifications

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // Get amount of pages:
    NSInteger numberOfPages = _pages.count;
    
    // Increase with 1 page when feature enabled:
    if (self.swipeToExit) {
        numberOfPages = numberOfPages + 1;
    }
    
    // Adjust contentSize of ScrollView:
    CGSize newContentSize = CGSizeMake(numberOfPages * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    if(self.scrollView.contentOffset.x > newContentSize.width) {
        CGPoint newOffset = self.scrollView.contentOffset;
        if (self.swipeToExit) {
            newOffset.x = newContentSize.width - (self.scrollView.frame.size.width * 2);
        } else {
            newOffset.x = newContentSize.width - self.scrollView.frame.size.width;
        }
        self.scrollView.contentOffset = newOffset;
    }
    self.scrollView.contentSize = newContentSize;
    
    // Adjust frame of each page:
    NSUInteger i = 0;
    for (EAIntroPage *page in _pages) {
        page.pageView.frame = CGRectMake(i * self.scrollView.bounds.size.width,
                                         0,
                                         self.scrollView.bounds.size.width,
                                         self.scrollView.bounds.size.height);
        i++;
    }
    
    // Adjust scrolling to fit resized page:
    CGFloat offset = self.currentPageIndex * self.scrollView.frame.size.width;
    CGRect pageRect = { .origin.x = offset, .origin.y = 0.0, .size.width = self.scrollView.frame.size.width, .size.height = self.scrollView.frame.size.height };
    [self.scrollView scrollRectToVisible:pageRect animated:NO];
    
    // Adjust restricted scroll area:
    if(!self.scrollingEnabled) {
        self.scrollView.restrictionArea = CGRectMake(self.visiblePageIndex * self.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    } else {
        self.scrollView.restrictionArea = CGRectZero;
    }
}

#pragma mark - Custom setters

- (void)setScrollingEnabled:(BOOL)scrollingEnabled {
    if(!scrollingEnabled) {
        self.scrollView.restrictionArea = CGRectMake(self.visiblePageIndex * self.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    } else {
        self.scrollView.restrictionArea = CGRectZero;
    }
    
    _scrollingEnabled = scrollingEnabled;
}

- (void)setPages:(NSArray *)pages {
    _pages = [pages copy];
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self buildScrollView];
    self.pageControl.numberOfPages = _pages.count;
}

- (void)setBgImage:(UIImage *)bgImage {
    _bgImage = bgImage;
    self.bgImageView.image = _bgImage;
    
    [self setNeedsDisplay];
}

- (void)setBgViewContentMode:(UIViewContentMode)bgViewContentMode {
    _bgViewContentMode = bgViewContentMode;
    self.bgImageView.contentMode = bgViewContentMode;
    self.pageBgBack.contentMode = bgViewContentMode;
    self.pageBgFront.contentMode = bgViewContentMode;
    
    [self setNeedsDisplay];
}

- (void)setSwipeToExit:(BOOL)swipeToExit {
    if (swipeToExit != _swipeToExit) {
        CGFloat contentXIndex = self.scrollView.contentSize.width;
        if(swipeToExit) {
            [self appendCloseViewAtXIndex:&contentXIndex];
        } else {
            [self removeCloseViewAtXIndex:&contentXIndex];
        }
        self.scrollView.contentSize = CGSizeMake(contentXIndex, self.scrollView.frame.size.height);
    }
    _swipeToExit = swipeToExit;
}

- (void)setTitleView:(UIView *)titleView {
    [_titleView removeFromSuperview];
    _titleView = titleView;
    
    if ([_titleView respondsToSelector:@selector(setTranslatesAutoresizingMaskIntoConstraints:)]) {
        _titleView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    CGFloat offset = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self crossDissolveForOffset:offset];
    
    [self buildTitleView];
    
    [self setNeedsDisplay];
}

- (void)setTitleViewY:(CGFloat)titleViewY {
    _titleViewY = titleViewY;
    
    [self buildTitleView];
    
    [self setNeedsDisplay];
}

- (void)setPageControl:(UIPageControl *)pageControl {
    if(!pageControl) {
        _pageControl.hidden = YES;
        return;
    }
    
    [_pageControl removeFromSuperview];
    _pageControl = pageControl;
    [self applyDefaultsToPageControl];
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setPageControlY:(CGFloat)pageControlY {
    _pageControlY = pageControlY;
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setSkipButton:(UIButton *)skipButton {
    if(!skipButton) {
        _skipButton.hidden = YES;
        return;
    }
    
    [_skipButton removeFromSuperview];
    _skipButton = skipButton;
    _skipButton.hidden = NO;
    [self applyDefaultsToSkipButton];
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setSkipButtonY:(CGFloat)skipButtonY {
    _skipButtonY = skipButtonY;
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setSkipButtonSideMargin:(CGFloat)skipButtonSideMargin {
    _skipButtonSideMargin = skipButtonSideMargin;
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setSkipButtonAlignment:(EAViewAlignment)skipButtonAlignment {
    _skipButtonAlignment = skipButtonAlignment;
    
    [self buildFooterView];
    
    [self setNeedsDisplay];
}

- (void)setShowSkipButtonOnlyOnLastPage:(BOOL)showSkipButtonOnlyOnLastPage {
    _showSkipButtonOnlyOnLastPage = showSkipButtonOnlyOnLastPage;
    
    CGFloat offset = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    [self crossDissolveForOffset:offset];
}

- (void)setUseMotionEffects:(BOOL)useMotionEffects {
    if(_useMotionEffects == useMotionEffects) {
        return;
    }
    _useMotionEffects = useMotionEffects;
    
    if(useMotionEffects) {
        [self addMotionEffectsOnBg];
    } else {
        [self removeMotionEffectsOnBg];
    }
}

- (void)setMotionEffectsRelativeValue:(CGFloat)motionEffectsRelativeValue {
    _motionEffectsRelativeValue = motionEffectsRelativeValue;
    if(self.useMotionEffects) {
        [self addMotionEffectsOnBg];
    }
}

#pragma mark - Motion effects actions

- (void)addMotionEffectsOnBg {
    if(![self respondsToSelector:@selector(setMotionEffects:)]) {
        return;
    }
    
    CGRect parallaxFrame = CGRectMake(-self.motionEffectsRelativeValue, -self.motionEffectsRelativeValue, self.bounds.size.width + (self.motionEffectsRelativeValue * 2), self.bounds.size.height + (self.motionEffectsRelativeValue * 2));
    [self.pageBgFront setFrame:parallaxFrame];
    [self.pageBgBack setFrame:parallaxFrame];
    [self.bgImageView setFrame:parallaxFrame];
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(self.motionEffectsRelativeValue);
    verticalMotionEffect.maximumRelativeValue = @(-self.motionEffectsRelativeValue);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(self.motionEffectsRelativeValue);
    horizontalMotionEffect.maximumRelativeValue = @(-self.motionEffectsRelativeValue);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to all background image views
    [UIView animateWithDuration:0.5f animations:^{
        [self.pageBgFront setMotionEffects:@[group]];
        [self.pageBgBack setMotionEffects:@[group]];
        [self.bgImageView setMotionEffects:@[group]];
    }];
}

- (void)removeMotionEffectsOnBg {
    if(![self respondsToSelector:@selector(removeMotionEffect:)]) {
        return;
    }
    
    [UIView animateWithDuration:0.5f animations:^{
        [self.pageBgFront removeMotionEffect:self.pageBgFront.motionEffects[0]];
        [self.pageBgBack removeMotionEffect:self.pageBgBack.motionEffects[0]];
        [self.bgImageView removeMotionEffect:self.bgImageView.motionEffects[0]];
    }];
}

#pragma mark - Actions

- (void)showFullscreen {
    [self showFullscreenWithAnimateDuration:0.3f andInitialPageIndex:0];
}

- (void)showFullscreenWithAnimateDuration:(CGFloat)duration {
    [self showFullscreenWithAnimateDuration:duration andInitialPageIndex:0];
}

- (void)showFullscreenWithAnimateDuration:(CGFloat)duration andInitialPageIndex:(NSUInteger)initialPageIndex {
    UIView *selectedView;
    
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            selectedView = window;
            break;
        }
    }
    
    [self showInView:selectedView animateDuration:duration withInitialPageIndex:initialPageIndex];
}

- (void)showInView:(UIView *)view {
    [self showInView:view animateDuration:0.3f withInitialPageIndex:0];
}

- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration {
    [self showInView:view animateDuration:duration withInitialPageIndex:0];
}

- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration withInitialPageIndex:(NSUInteger)initialPageIndex {
    if(![self pageForIndex:initialPageIndex]) {
        NSLog(@"Wrong initialPageIndex received: %ld",(long)initialPageIndex);
        return;
    }
    
    self.currentPageIndex = initialPageIndex;
    self.alpha = 0;

    if(self.superview != view) {
        [view addSubview:self];
    } else {
        [view bringSubviewToFront:self];
    }
   
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        EAIntroPage *currentPage = _pages[self.currentPageIndex];
        if(currentPage.onPageDidAppear) currentPage.onPageDidAppear();
        
        if ([(id)self.delegate respondsToSelector:@selector(intro:pageAppeared:withIndex:)]) {
            [self.delegate intro:self pageAppeared:_pages[self.currentPageIndex] withIndex:self.currentPageIndex];
        }
    }];
}

- (void)hideWithFadeOutDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
		[self finishIntroductionAndRemoveSelf];
	}];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex {
    [self setCurrentPageIndex:currentPageIndex animated:NO];
}

- (void)setCurrentPageIndex:(NSUInteger)currentPageIndex animated:(BOOL)animated {
    if(![self pageForIndex:currentPageIndex]) {
        NSLog(@"Wrong currentPageIndex received: %ld",(long)currentPageIndex);
        return;
    }
    
    CGFloat offset = currentPageIndex * self.scrollView.frame.size.width;
    CGRect pageRect = { .origin.x = offset, .origin.y = 0.0, .size.width = self.scrollView.frame.size.width, .size.height = self.scrollView.frame.size.height };
    [self.scrollView scrollRectToVisible:pageRect animated:animated];
}

- (IBAction)goToNext:(id)sender {
    if(!self.tapToNext) {
        return;
    }
    if(self.currentPageIndex + 1 >= [self.pages count]) {
        [self hideWithFadeOutDuration:0.3];
    } else {
        [self setCurrentPageIndex:self.currentPageIndex + 1 animated:YES];
    }
}

- (void)limitScrollingToPage:(NSUInteger)lastPageIndex {
    if (lastPageIndex >= [self.pages count]) {
        self.scrollingEnabled = YES;
        return;
    }
    
    _scrollingEnabled = YES;
    self.scrollView.restrictionArea = CGRectMake(0, 0, (lastPageIndex + 1) * self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
}

@end
