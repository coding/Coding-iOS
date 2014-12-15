//
//  SMPageControl.m
//  SMPageControl
//
//  Created by Jerry Jones on 10/13/12.
//  Copyright (c) 2012 Spaceman Labs. All rights reserved.
//

#import "SMPageControl.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif


#define DEFAULT_INDICATOR_WIDTH 6.0f
#define DEFAULT_INDICATOR_MARGIN 10.0f
#define DEFAULT_MIN_HEIGHT 36.0f

#define DEFAULT_INDICATOR_WIDTH_LARGE 7.0f
#define DEFAULT_INDICATOR_MARGIN_LARGE 9.0f
#define DEFAULT_MIN_HEIGHT_LARGE 36.0f

typedef NS_ENUM(NSUInteger, SMPageControlImageType) {
	SMPageControlImageTypeNormal = 1,
	SMPageControlImageTypeCurrent,
	SMPageControlImageTypeMask
};

typedef NS_ENUM(NSUInteger, SMPageControlStyleDefaults) {
	SMPageControlDefaultStyleClassic = 0,
	SMPageControlDefaultStyleModern
};

static SMPageControlStyleDefaults _defaultStyleForSystemVersion;

@interface SMPageControl ()
@property (strong, readonly, nonatomic) NSMutableDictionary *pageNames;
@property (strong, readonly, nonatomic) NSMutableDictionary *pageImages;
@property (strong, readonly, nonatomic) NSMutableDictionary *currentPageImages;
@property (strong, readonly, nonatomic) NSMutableDictionary *pageImageMasks;
@property (strong, readonly, nonatomic) NSMutableDictionary *cgImageMasks;
@property (strong, readwrite, nonatomic) NSArray *pageRects;

// Page Control used for stealing page number localizations for accessibility labels
// I'm not sure I love this technique, but it's the best way to get exact translations for all the languages
// that Apple supports out of the box
@property (nonatomic, strong) UIPageControl *accessibilityPageControl;
@end

@implementation SMPageControl
{
@private
    NSInteger			_displayedPage;
	CGFloat				_measuredIndicatorWidth;
	CGFloat				_measuredIndicatorHeight;
	CGImageRef			_pageImageMask;
}

@synthesize pageNames = _pageNames;
@synthesize pageImages = _pageImages;
@synthesize currentPageImages = _currentPageImages;
@synthesize pageImageMasks = _pageImageMasks;
@synthesize cgImageMasks = _cgImageMasks;

+ (void)initialize
{
	NSString *reqSysVer = @"7.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
		_defaultStyleForSystemVersion = SMPageControlDefaultStyleModern;
	} else {
		_defaultStyleForSystemVersion = SMPageControlDefaultStyleClassic;
	}
}

- (void)_initialize
{
	_numberOfPages = 0;
	_tapBehavior = SMPageControlTapBehaviorStep;
    
	self.backgroundColor = [UIColor clearColor];
	
	// If the app wasn't linked against iOS 7 or newer, always use the classic style
	// otherwise, use the style of the current OS.
#ifdef __IPHONE_7_0
	[self setStyleWithDefaults:_defaultStyleForSystemVersion];
#else
	[self setStyleWithDefaults:SMPageControlDefaultStyleClassic];
#endif
	
	_alignment = SMPageControlAlignmentCenter;
	_verticalAlignment = SMPageControlVerticalAlignmentMiddle;
	
	self.isAccessibilityElement = YES;
	self.accessibilityTraits = UIAccessibilityTraitUpdatesFrequently;
	self.accessibilityPageControl = [[UIPageControl alloc] init];
	self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (nil == self) {
		return nil;
    }
	
	[self _initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil == self) {
        return nil;
    }

    [self _initialize];
    return self;
}

- (void)dealloc
{
	if (_pageImageMask) {
		CGImageRelease(_pageImageMask);
	}	
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self _renderPages:context rect:rect];
}

- (void)_renderPages:(CGContextRef)context rect:(CGRect)rect
{
	NSMutableArray *pageRects = [NSMutableArray arrayWithCapacity:self.numberOfPages];
    
	if (_numberOfPages < 2 && _hidesForSinglePage) {
		return;
	}
		
	CGFloat left = [self _leftOffset];
		
	CGFloat xOffset = left;
	CGFloat yOffset = 0.0f;
	UIColor *fillColor = nil;
	UIImage *image = nil;
	CGImageRef maskingImage = nil;
	CGSize maskSize = CGSizeZero;
	
	for (NSInteger i = 0; i < _numberOfPages; i++) {
		NSNumber *indexNumber = @(i);
		
		if (i == _displayedPage) {
			fillColor = _currentPageIndicatorTintColor ? _currentPageIndicatorTintColor : [UIColor whiteColor];
			image = _currentPageImages[indexNumber];
			if (nil == image) {
				image = _currentPageIndicatorImage;
			}
		} else {
			fillColor = _pageIndicatorTintColor ? _pageIndicatorTintColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
			image = _pageImages[indexNumber];
			if (nil == image) {
				image = _pageIndicatorImage;
			}
		}
		
		// If no finished images have been set, try a masking image
		if (nil == image) {
			maskingImage = (__bridge CGImageRef)_cgImageMasks[indexNumber];
			UIImage *originalImage = _pageImageMasks[indexNumber];
			maskSize = originalImage.size;

			// If no per page mask is set, try for a global page mask!
			if (nil == maskingImage) {
				maskingImage = _pageImageMask;
				maskSize = _pageIndicatorMaskImage.size;
			}
		}
				
		[fillColor set];
		CGRect indicatorRect;
		if (image) {
			yOffset = [self _topOffsetForHeight:image.size.height rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - image.size.width) / 2.0f);
			[image drawAtPoint:CGPointMake(centeredXOffset, yOffset)];
            indicatorRect = CGRectMake(centeredXOffset, yOffset, image.size.width, image.size.height);
		} else if (maskingImage) {
			yOffset = [self _topOffsetForHeight:maskSize.height rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - maskSize.width) / 2.0f);
			indicatorRect = CGRectMake(centeredXOffset, yOffset, maskSize.width, maskSize.height);
			CGContextDrawImage(context, indicatorRect, maskingImage);
		} else {
			yOffset = [self _topOffsetForHeight:_indicatorDiameter rect:rect];
			CGFloat centeredXOffset = xOffset + floorf((_measuredIndicatorWidth - _indicatorDiameter) / 2.0f);
            indicatorRect = CGRectMake(centeredXOffset, yOffset, _indicatorDiameter, _indicatorDiameter);
			CGContextFillEllipseInRect(context, indicatorRect);
		}
		
        [pageRects addObject:[NSValue valueWithCGRect:indicatorRect]];
		maskingImage = NULL;
		xOffset += _measuredIndicatorWidth + _indicatorMargin;
	}
	
	self.pageRects = pageRects;
	
}

- (CGFloat)_leftOffset
{
	CGRect rect = self.bounds;
	CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
	CGFloat left = 0.0f;
	switch (_alignment) {
		case SMPageControlAlignmentCenter:
			left = ceilf(CGRectGetMidX(rect) - (size.width / 2.0f));
			break;
		case SMPageControlAlignmentRight:
			left = CGRectGetMaxX(rect) - size.width;
			break;
		default:
			break;
	}
	
	return left;
}

- (CGFloat)_topOffsetForHeight:(CGFloat)height rect:(CGRect)rect
{
	CGFloat top = 0.0f;
	switch (_verticalAlignment) {
		case SMPageControlVerticalAlignmentMiddle:
			top = CGRectGetMidY(rect) - (height / 2.0f);
			break;
		case SMPageControlVerticalAlignmentBottom:
			top = CGRectGetMaxY(rect) - height;
			break;
		default:
			break;
	}
	
	return top;
}

- (void)updateCurrentPageDisplay
{
	_displayedPage = _currentPage;
	[self setNeedsDisplay];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGFloat marginSpace = MAX(0, pageCount - 1) * _indicatorMargin;
	CGFloat indicatorSpace = pageCount * _measuredIndicatorWidth;
	CGSize size = CGSizeMake(marginSpace + indicatorSpace, _measuredIndicatorHeight);
	return size;
}

- (CGRect)rectForPageIndicator:(NSInteger)pageIndex
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return CGRectZero;
	}
	
	CGFloat left = [self _leftOffset];
	CGSize size = [self sizeForNumberOfPages:pageIndex + 1];
	CGRect rect = CGRectMake(left + size.width - _measuredIndicatorWidth, 0, _measuredIndicatorWidth, _measuredIndicatorWidth);
	return rect;
}

- (void)_setImage:(UIImage *)image forPage:(NSInteger)pageIndex type:(SMPageControlImageType)type
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return;
	}
	
	NSMutableDictionary *dictionary = nil;
	switch (type) {
		case SMPageControlImageTypeCurrent:
			dictionary = self.currentPageImages;
			break;
		case SMPageControlImageTypeNormal:
			dictionary = self.pageImages;
			break;
		case SMPageControlImageTypeMask:
			dictionary = self.pageImageMasks;
			break;
		default:
			break;
	}
    
    if (image) {
        dictionary[@(pageIndex)] = image;
    } else {
        [dictionary removeObjectForKey:@(pageIndex)];
    }
}

- (void)setImage:(UIImage *)image forPage:(NSInteger)pageIndex
{
    [self _setImage:image forPage:pageIndex type:SMPageControlImageTypeNormal];
	[self _updateMeasuredIndicatorSizes];
}

- (void)setCurrentImage:(UIImage *)image forPage:(NSInteger)pageIndex
{
	[self _setImage:image forPage:pageIndex type:SMPageControlImageTypeCurrent];;
	[self _updateMeasuredIndicatorSizes];
}

- (void)setImageMask:(UIImage *)image forPage:(NSInteger)pageIndex
{
	[self _setImage:image forPage:pageIndex type:SMPageControlImageTypeMask];
	
	if (nil == image) {
		[self.cgImageMasks removeObjectForKey:@(pageIndex)];
		return;
	}
	
	CGImageRef maskImage = [self createMaskForImage:image];

	if (maskImage) {
		self.cgImageMasks[@(pageIndex)] = (__bridge id)maskImage;
		CGImageRelease(maskImage);
		[self _updateMeasuredIndicatorSizeWithSize:image.size];
		[self setNeedsDisplay];
	}
}

- (id)_imageForPage:(NSInteger)pageIndex type:(SMPageControlImageType)type
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return nil;
	}
	
	NSDictionary *dictionary = nil;
	switch (type) {
		case SMPageControlImageTypeCurrent:
			dictionary = _currentPageImages;
			break;
		case SMPageControlImageTypeNormal:
			dictionary = _pageImages;
			break;
		case SMPageControlImageTypeMask:
			dictionary = _pageImageMasks;
			break;
		default:
			break;
	}
	
	return dictionary[@(pageIndex)];
}

- (UIImage *)imageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeNormal];
}

- (UIImage *)currentImageForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeCurrent];
}

- (UIImage *)imageMaskForPage:(NSInteger)pageIndex
{
	return [self _imageForPage:pageIndex type:SMPageControlImageTypeMask];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGSize sizeThatFits = [self sizeForNumberOfPages:self.numberOfPages];
	sizeThatFits.height = MAX(sizeThatFits.height, _minHeight);
	return sizeThatFits;
}

- (CGSize)intrinsicContentSize
{
	if (_numberOfPages < 1 || (_numberOfPages < 2 && _hidesForSinglePage)) {
		return CGSizeMake(UIViewNoIntrinsicMetric, 0.0f);
	}
	CGSize intrinsicContentSize = CGSizeMake(UIViewNoIntrinsicMetric, MAX(_measuredIndicatorHeight, _minHeight));
	return intrinsicContentSize;
}

- (void)updatePageNumberForScrollView:(UIScrollView *)scrollView
{
	NSInteger page = (int)floorf(scrollView.contentOffset.x / scrollView.bounds.size.width);
	self.currentPage = page;
}

- (void)setScrollViewContentOffsetForCurrentPage:(UIScrollView *)scrollView animated:(BOOL)animated
{
	CGPoint offset = scrollView.contentOffset;
	offset.x = scrollView.bounds.size.width * self.currentPage;
	[scrollView setContentOffset:offset animated:animated];
}

- (void)setStyleWithDefaults:(SMPageControlStyleDefaults)defaultStyle
{
	switch (defaultStyle) {
		case SMPageControlDefaultStyleModern:
			self.indicatorDiameter = DEFAULT_INDICATOR_WIDTH_LARGE;
			self.indicatorMargin = DEFAULT_INDICATOR_MARGIN_LARGE;
			self.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2f];
			self.minHeight = DEFAULT_MIN_HEIGHT_LARGE;
			break;
		case SMPageControlDefaultStyleClassic:
		default:
			self.indicatorDiameter = DEFAULT_INDICATOR_WIDTH;
			self.indicatorMargin = DEFAULT_INDICATOR_MARGIN;
			self.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
			self.minHeight = DEFAULT_MIN_HEIGHT;
			break;
	}
}

#pragma mark -

- (CGImageRef)createMaskForImage:(UIImage *)image CF_RETURNS_RETAINED
{
	size_t pixelsWide = image.size.width * image.scale;
	size_t pixelsHigh = image.size.height * image.scale;
	size_t bitmapBytesPerRow = (pixelsWide * 1);
	CGContextRef context = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, CGImageGetBitsPerComponent(image.CGImage), bitmapBytesPerRow, NULL, (CGBitmapInfo)kCGImageAlphaOnly);
	CGContextTranslateCTM(context, 0.f, pixelsHigh);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	
	CGContextDrawImage(context, CGRectMake(0, 0, pixelsWide, pixelsHigh), image.CGImage);
	CGImageRef maskImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);

	return maskImage;
}

- (void)_updateMeasuredIndicatorSizeWithSize:(CGSize)size
{
	_measuredIndicatorWidth = MAX(_measuredIndicatorWidth, size.width);
	_measuredIndicatorHeight = MAX(_measuredIndicatorHeight, size.height);
}

- (void)_updateMeasuredIndicatorSizes
{
	_measuredIndicatorWidth = _indicatorDiameter;
	_measuredIndicatorHeight = _indicatorDiameter;
	
	// If we're only using images, ignore the _indicatorDiameter
	if ( (self.pageIndicatorImage || self.pageIndicatorMaskImage) && self.currentPageIndicatorImage )
	{
		_measuredIndicatorWidth = 0;
		_measuredIndicatorHeight = 0;
	}
	
	if (self.pageIndicatorImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.pageIndicatorImage.size];
	}
	
	if (self.currentPageIndicatorImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.currentPageIndicatorImage.size];
	}
	
	if (self.pageIndicatorMaskImage) {
		[self _updateMeasuredIndicatorSizeWithSize:self.pageIndicatorMaskImage.size];
	}

	if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
		[self invalidateIntrinsicContentSize];
	}
}


#pragma mark - Tap Gesture

// We're using touchesEnded: because we want to mimick UIPageControl as close as possible
// As of iOS 6, UIPageControl still (as far as we know) does not use a tap gesture recognizer. This means that actions like
// touching down, sliding around, and releasing, still results in the page incrementing or decrementing.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
    
    if (SMPageControlTapBehaviorJump == self.tapBehavior) {
		
        __block NSInteger tappedIndicatorIndex = NSNotFound;
		
        [self.pageRects enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger index, BOOL *stop) {
            CGRect indicatorRect = [value CGRectValue];
						
            if (CGRectContainsPoint(indicatorRect, point)) {
                tappedIndicatorIndex = index;
                *stop = YES;
            }
        }];
        
        if (NSNotFound != tappedIndicatorIndex) {
            [self setCurrentPage:tappedIndicatorIndex sendEvent:YES canDefer:YES];
            return;
        }
    }
    
    CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
    CGFloat left = [self _leftOffset];
    CGFloat middle = left + (size.width / 2.0f);
    if (point.x < middle) {
        [self setCurrentPage:self.currentPage - 1 sendEvent:YES canDefer:YES];
    } else {
        [self setCurrentPage:self.currentPage + 1 sendEvent:YES canDefer:YES];
    }
    
}

#pragma mark - Accessors

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self setNeedsDisplay];
}

- (void)setIndicatorDiameter:(CGFloat)indicatorDiameter
{
	if (indicatorDiameter == _indicatorDiameter) {
		return;
	}
	
	_indicatorDiameter = indicatorDiameter;

	// Absolute minimum height of the control is the indicator diameter
	if (_minHeight < indicatorDiameter) {
		self.minHeight = indicatorDiameter;
	}

	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setIndicatorMargin:(CGFloat)indicatorMargin
{
	if (indicatorMargin == _indicatorMargin) {
		return;
	}
	
	_indicatorMargin = indicatorMargin;
	[self setNeedsDisplay];
}

- (void)setMinHeight:(CGFloat)minHeight
{
	if (minHeight == _minHeight) {
		return;
	}

   // Absolute minimum height of the control is the indicator diameter
	if (minHeight < _indicatorDiameter) {
		minHeight = _indicatorDiameter;
	}

	_minHeight = minHeight;
	if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
		[self invalidateIntrinsicContentSize];
	}
	[self setNeedsLayout];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
	if (numberOfPages == _numberOfPages) {
		return;
	}
	
	self.accessibilityPageControl.numberOfPages = numberOfPages;
	
	_numberOfPages = MAX(0, numberOfPages);
	if ([self respondsToSelector:@selector(invalidateIntrinsicContentSize)]) {
		[self invalidateIntrinsicContentSize];
	}
	[self updateAccessibilityValue];
	[self setNeedsDisplay];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
	[self setCurrentPage:currentPage sendEvent:NO canDefer:NO];
}

- (void)setCurrentPage:(NSInteger)currentPage sendEvent:(BOOL)sendEvent canDefer:(BOOL)defer
{	
	_currentPage = MIN(MAX(0, currentPage), _numberOfPages - 1);
	self.accessibilityPageControl.currentPage = self.currentPage;
	
	[self updateAccessibilityValue];
	
	if (NO == self.defersCurrentPageDisplay || NO == defer) {
		_displayedPage = _currentPage;
		[self setNeedsDisplay];
	}
	
	if (sendEvent) {
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}
}

- (void)setCurrentPageIndicatorImage:(UIImage *)currentPageIndicatorImage
{
	if ([currentPageIndicatorImage isEqual:_currentPageIndicatorImage]) {
		return;
	}
	
	_currentPageIndicatorImage = currentPageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setPageIndicatorImage:(UIImage *)pageIndicatorImage
{
	if ([pageIndicatorImage isEqual:_pageIndicatorImage]) {
		return;
	}
	
	_pageIndicatorImage = pageIndicatorImage;
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (void)setPageIndicatorMaskImage:(UIImage *)pageIndicatorMaskImage
{
	if ([pageIndicatorMaskImage isEqual:_pageIndicatorMaskImage]) {
		return;
	}
	
	_pageIndicatorMaskImage = pageIndicatorMaskImage;
	
	if (_pageImageMask) {
		CGImageRelease(_pageImageMask);
	}
	
	_pageImageMask = [self createMaskForImage:_pageIndicatorMaskImage];
	
	[self _updateMeasuredIndicatorSizes];
	[self setNeedsDisplay];
}

- (NSMutableDictionary *)pageNames
{
	if (nil != _pageNames) {
		return _pageNames;
	}
	
	_pageNames = [[NSMutableDictionary alloc] init];
	return _pageNames;
}

- (NSMutableDictionary *)pageImages
{
	if (nil != _pageImages) {
		return _pageImages;
	}
	
	_pageImages = [[NSMutableDictionary alloc] init];
	return _pageImages;
}

- (NSMutableDictionary *)currentPageImages
{
	if (nil != _currentPageImages) {
		return _currentPageImages;
	}
	
	_currentPageImages = [[NSMutableDictionary alloc] init];
	return _currentPageImages;
}

- (NSMutableDictionary *)pageImageMasks
{
	if (nil != _pageImageMasks) {
		return _pageImageMasks;
	}
	
	_pageImageMasks = [[NSMutableDictionary alloc] init];
	return _pageImageMasks;
}

- (NSMutableDictionary *)cgImageMasks
{
	if (nil != _cgImageMasks) {
		return _cgImageMasks;
	}
	
	_cgImageMasks = [[NSMutableDictionary alloc] init];
	return _cgImageMasks;
}

#pragma mark - UIAccessibility

- (void)setName:(NSString *)name forPage:(NSInteger)pageIndex
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return;
	}
	
	self.pageNames[@(pageIndex)] = name;
	
}

- (NSString *)nameForPage:(NSInteger)pageIndex
{
	if (pageIndex < 0 || pageIndex >= _numberOfPages) {
		return nil;
	}
	
	return self.pageNames[@(pageIndex)];
}

- (void)updateAccessibilityValue
{
	NSString *pageName = [self nameForPage:self.currentPage];
	NSString *accessibilityValue = self.accessibilityPageControl.accessibilityValue;
	
	if (pageName) {
		self.accessibilityValue = [NSString stringWithFormat:@"%@ - %@", pageName, accessibilityValue];
	} else {
		self.accessibilityValue = accessibilityValue;
	}
}

@end
