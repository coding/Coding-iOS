//
//  SMPageControl.h
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SMPageControlAlignment) {
	SMPageControlAlignmentLeft = 1,
	SMPageControlAlignmentCenter,
	SMPageControlAlignmentRight
};

typedef NS_ENUM(NSUInteger, SMPageControlVerticalAlignment) {
	SMPageControlVerticalAlignmentTop = 1,
	SMPageControlVerticalAlignmentMiddle,
	SMPageControlVerticalAlignmentBottom
};

typedef NS_ENUM(NSUInteger, SMPageControlTapBehavior) {
	SMPageControlTapBehaviorStep	= 1,
	SMPageControlTapBehaviorJump
};

@interface SMPageControl : UIControl

@property (nonatomic) NSInteger numberOfPages;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) CGFloat indicatorMargin							UI_APPEARANCE_SELECTOR; // deafult is 10
@property (nonatomic) CGFloat indicatorDiameter							UI_APPEARANCE_SELECTOR; // deafult is 6
@property (nonatomic) CGFloat minHeight									UI_APPEARANCE_SELECTOR; // default is 36, cannot be less than indicatorDiameter
@property (nonatomic) SMPageControlAlignment alignment					UI_APPEARANCE_SELECTOR; // deafult is Center
@property (nonatomic) SMPageControlVerticalAlignment verticalAlignment	UI_APPEARANCE_SELECTOR;	// deafult is Middle

@property (nonatomic, strong) UIImage *pageIndicatorImage				UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *pageIndicatorMaskImage			UI_APPEARANCE_SELECTOR; // ignored if pageIndicatorImage is set
@property (nonatomic, strong) UIColor *pageIndicatorTintColor			UI_APPEARANCE_SELECTOR; // ignored if pageIndicatorImage is set
@property (nonatomic, strong) UIImage *currentPageIndicatorImage		UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor	UI_APPEARANCE_SELECTOR; // ignored if currentPageIndicatorImage is set

@property (nonatomic) BOOL hidesForSinglePage;			// hide the the indicator if there is only one page. default is NO
@property (nonatomic) BOOL defersCurrentPageDisplay;	// if set, clicking to a new page won't update the currently displayed page until -updateCurrentPageDisplay is called. default is NO

@property (nonatomic) SMPageControlTapBehavior tapBehavior;	// SMPageControlTapBehaviorStep provides an increment/decrement behavior exactly like UIPageControl. SMPageControlTapBehaviorJump allows specific pages to be selected by tapping their respective indicator. Default is SMPageControlTapBehaviorStep

- (void)updateCurrentPageDisplay;						// update page display to match the currentPage. ignored if defersCurrentPageDisplay is NO. setting the page value directly will update immediately

- (CGRect)rectForPageIndicator:(NSInteger)pageIndex;
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

- (void)setImage:(UIImage *)image forPage:(NSInteger)pageIndex;
- (void)setCurrentImage:(UIImage *)image forPage:(NSInteger)pageIndex;
- (void)setImageMask:(UIImage *)image forPage:(NSInteger)pageIndex;

- (UIImage *)imageForPage:(NSInteger)pageIndex;
- (UIImage *)currentImageForPage:(NSInteger)pageIndex;
- (UIImage *)imageMaskForPage:(NSInteger)pageIndex;

- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView;
- (void)setScrollViewContentOffsetForCurrentPage:(UIScrollView *)scrollView animated:(BOOL)animated;

#pragma mark - UIAccessibility

// SMPageControl mirrors UIPageControl's standard accessibility functionality by default.
// Basically, the accessibility label is set to "[current page index + 1] of [page count]".

// SMPageControl extends UIPageControl's functionality by allowing you to name specific pages. This is especially useful when using
// the per-page indicator images, and allows you to provide more context to the user.

- (void)setName:(NSString *)name forPage:(NSInteger)pageIndex;
- (NSString *)nameForPage:(NSInteger)pageIndex;

@end 
