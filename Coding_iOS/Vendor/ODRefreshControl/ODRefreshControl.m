//
//  ODRefreshControl.m
//  ODRefreshControl
//
//  Created by Fabio Ritrovato on 6/13/12.
//  Copyright (c) 2012 orange in a day. All rights reserved.
//
// https://github.com/Sephiroth87/ODRefreshControl
//

#import "ODRefreshControl.h"

#define kTotalViewHeight    400
#define kOpenedViewHeight   44
#define kMinTopPadding      9
#define kMaxTopPadding      5
#define kMinTopRadius       12.5
#define kMaxTopRadius       16
#define kMinBottomRadius    3
#define kMaxBottomRadius    16
#define kMinBottomPadding   4
#define kMaxBottomPadding   6
#define kMinArrowSize       2
#define kMaxArrowSize       3
#define kMinArrowRadius     5
#define kMaxArrowRadius     7
#define kMaxDistance        53

@interface ODRefreshControl ()

@property (nonatomic, readwrite) BOOL refreshing, duringEnding;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets originalContentInset;

@end

@implementation ODRefreshControl

@synthesize refreshing = _refreshing;
@synthesize tintColor = _tintColor;

@synthesize scrollView = _scrollView;
@synthesize originalContentInset = _originalContentInset;

static inline CGFloat lerp(CGFloat a, CGFloat b, CGFloat p)
{
    return a + (b - a) * p;
}

- (id)initInScrollView:(UIScrollView *)scrollView {
    return [self initInScrollView:scrollView activityIndicatorView:nil];
}

- (id)initInScrollView:(UIScrollView *)scrollView activityIndicatorView:(UIView *)activity
{
    self = [super initWithFrame:CGRectMake(0, -(kTotalViewHeight + scrollView.contentInset.top), scrollView.frame.size.width, kTotalViewHeight)];
    
    if (self) {
        self.scrollView = scrollView;
        self.originalContentInset = scrollView.contentInset;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [scrollView addSubview:self];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
        
        _activity = activity ? activity : [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.center = CGPointMake(floor(self.frame.size.width / 2), floor(self.frame.size.height / 2));
        _activity.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _activity.alpha = 0;
        if ([_activity respondsToSelector:@selector(startAnimating)]) {
            [(UIActivityIndicatorView *)_activity startAnimating];
        }
        [self addSubview:_activity];
        
        _refreshing = NO;
        _duringEnding = NO;
        _canRefresh = YES;
        _ignoreInset = NO;
        _ignoreOffset = NO;
        _didSetInset = NO;
        _hasSectionHeaders = NO;
        _tintColor = [UIColor colorWithRed:155.0 / 255.0 green:162.0 / 255.0 blue:172.0 / 255.0 alpha:1.0];
        
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [_tintColor CGColor];
        _shapeLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
        _shapeLayer.lineWidth = 0.5;
        _shapeLayer.shadowColor = [[UIColor blackColor] CGColor];
        _shapeLayer.shadowOffset = CGSizeMake(0, 1);
        _shapeLayer.shadowOpacity = 0.4;
        _shapeLayer.shadowRadius = 0.5;
        [self.layer addSublayer:_shapeLayer];
        
        _arrowLayer = [CAShapeLayer layer];
        _arrowLayer.strokeColor = [[[UIColor darkGrayColor] colorWithAlphaComponent:0.5] CGColor];
        _arrowLayer.lineWidth = 0.5;
        _arrowLayer.fillColor = [[UIColor whiteColor] CGColor];
        [_shapeLayer addSublayer:_arrowLayer];
        
        _highlightLayer = [CAShapeLayer layer];
        _highlightLayer.fillColor = [[[UIColor whiteColor] colorWithAlphaComponent:0.2] CGColor];
        [_shapeLayer addSublayer:_highlightLayer];
    }
    return self;
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    self.scrollView = nil;
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    _shapeLayer.hidden = !self.enabled;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
        self.scrollView = nil;
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    _shapeLayer.fillColor = [_tintColor CGColor];
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)_activity setActivityIndicatorViewStyle:activityIndicatorViewStyle];
    }
}

- (UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    if ([_activity isKindOfClass:[UIActivityIndicatorView class]]) {
        return [(UIActivityIndicatorView *)_activity activityIndicatorViewStyle];
    }
    return 0;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentInset"]) {
        if (!_ignoreInset) {
            self.originalContentInset = [[change objectForKey:@"new"] UIEdgeInsetsValue];
            self.frame = CGRectMake(0, -(kTotalViewHeight + self.scrollView.contentInset.top), self.scrollView.frame.size.width, kTotalViewHeight);
        }
        return;
    }
    
    if (!self.enabled || _ignoreOffset) {
        return;
    }

    CGFloat offset = [[change objectForKey:@"new"] CGPointValue].y + self.originalContentInset.top;
    
    if (_refreshing) {
        if (offset != 0) {
            // Keep thing pinned at the top
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _shapeLayer.position = CGPointMake(0, kMaxDistance + offset + kOpenedViewHeight);
            [CATransaction commit];

            _activity.center = CGPointMake(floor(self.frame.size.width / 2), MIN(offset + self.frame.size.height + floor(kOpenedViewHeight / 2), self.frame.size.height - kOpenedViewHeight/ 2));

            _ignoreInset = YES;
            _ignoreOffset = YES;
            
            if (offset < 0) {
                // Set the inset depending on the situation
                if (offset >= -kOpenedViewHeight) {
                    if (!self.scrollView.dragging) {
                        if (!_didSetInset) {
                            _didSetInset = YES;
                            _hasSectionHeaders = NO;
                            if([self.scrollView isKindOfClass:[UITableView class]]){
                                for (int i = 0; i < [(UITableView *)self.scrollView numberOfSections]; ++i) {
                                    if ([(UITableView *)self.scrollView rectForHeaderInSection:i].size.height) {
                                        _hasSectionHeaders = YES;
                                        break;
                                    }
                                }
                            }
                        }
                        if (_hasSectionHeaders) {
                            [self.scrollView setContentInset:UIEdgeInsetsMake(MIN(-offset, kOpenedViewHeight) + self.originalContentInset.top, self.originalContentInset.left, self.originalContentInset.bottom, self.originalContentInset.right)];
                        } else {
                            [self.scrollView setContentInset:UIEdgeInsetsMake(kOpenedViewHeight + self.originalContentInset.top, self.originalContentInset.left, self.originalContentInset.bottom, self.originalContentInset.right)];
                        }
                    } else if (_didSetInset && _hasSectionHeaders) {
                        [self.scrollView setContentInset:UIEdgeInsetsMake(-offset + self.originalContentInset.top, self.originalContentInset.left, self.originalContentInset.bottom, self.originalContentInset.right)];
                    }
                }
            } else if (_hasSectionHeaders) {
                [self.scrollView setContentInset:self.originalContentInset];
            }
            _ignoreInset = NO;
            _ignoreOffset = NO;
        }
        return;
    } else {
        // Check if we can trigger a new refresh
        if (!_canRefresh) {
            if (offset >= 0) {
                _canRefresh = YES;
                _didSetInset = NO;
            } else {
                return;
            }
        } else {
            if (offset >= 0) {
                return;
            }
        }
    }
    
    BOOL triggered = NO;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    //Calculate some useful points and values
    CGFloat verticalShift = MAX(0, -((kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding) + offset));
    CGFloat distance = MIN(kMaxDistance, fabs(verticalShift));
    CGFloat percentage = 1 - (distance / kMaxDistance);
    
    CGFloat currentTopPadding = lerp(kMinTopPadding, kMaxTopPadding, percentage);
    CGFloat currentTopRadius = lerp(kMinTopRadius, kMaxTopRadius, percentage);
    CGFloat currentBottomRadius = lerp(kMinBottomRadius, kMaxBottomRadius, percentage);
    CGFloat currentBottomPadding =  lerp(kMinBottomPadding, kMaxBottomPadding, percentage);
    
    CGPoint bottomOrigin = CGPointMake(floor(self.bounds.size.width / 2), self.bounds.size.height - currentBottomPadding -currentBottomRadius);
    CGPoint topOrigin = CGPointZero;
    if (distance == 0) {
        topOrigin = CGPointMake(floor(self.bounds.size.width / 2), bottomOrigin.y);
    } else {
        topOrigin = CGPointMake(floor(self.bounds.size.width / 2), self.bounds.size.height + offset + currentTopPadding + currentTopRadius);
        if (percentage == 0) {
            bottomOrigin.y -= (fabs(verticalShift) - kMaxDistance);
            triggered = YES;
        }
    }
    
    //Top semicircle
    CGPathAddArc(path, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
    
    //Left curve
    CGPoint leftCp1 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint leftCp2 = CGPointMake(lerp((topOrigin.x - currentTopRadius), (bottomOrigin.x - currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint leftDestination = CGPointMake(bottomOrigin.x - currentBottomRadius, bottomOrigin.y);
    
    CGPathAddCurveToPoint(path, NULL, leftCp1.x, leftCp1.y, leftCp2.x, leftCp2.y, leftDestination.x, leftDestination.y);
    
    //Bottom semicircle
    CGPathAddArc(path, NULL, bottomOrigin.x, bottomOrigin.y, currentBottomRadius, M_PI, 0, YES);
    
    //Right curve
    CGPoint rightCp2 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.1), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint rightCp1 = CGPointMake(lerp((topOrigin.x + currentTopRadius), (bottomOrigin.x + currentBottomRadius), 0.9), lerp(topOrigin.y, bottomOrigin.y, 0.2));
    CGPoint rightDestination = CGPointMake(topOrigin.x + currentTopRadius, topOrigin.y);
    
    CGPathAddCurveToPoint(path, NULL, rightCp1.x, rightCp1.y, rightCp2.x, rightCp2.y, rightDestination.x, rightDestination.y);
    CGPathCloseSubpath(path);
    
    if (!triggered) {
        // Set paths
        
        _shapeLayer.path = path;
        _shapeLayer.shadowPath = path;
        
        // Add the arrow shape
        
        CGFloat currentArrowSize = lerp(kMinArrowSize, kMaxArrowSize, percentage);
        CGFloat currentArrowRadius = lerp(kMinArrowRadius, kMaxArrowRadius, percentage);
        CGFloat arrowBigRadius = currentArrowRadius + (currentArrowSize / 2);
        CGFloat arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2);
        CGMutablePathRef arrowPath = CGPathCreateMutable();
        CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowBigRadius, 0, 3 * M_PI_2, NO);
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius - currentArrowSize);
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x + (2 * currentArrowSize), topOrigin.y - arrowBigRadius + (currentArrowSize / 2));
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius + (2 * currentArrowSize));
        CGPathAddLineToPoint(arrowPath, NULL, topOrigin.x, topOrigin.y - arrowBigRadius + currentArrowSize);
        CGPathAddArc(arrowPath, NULL, topOrigin.x, topOrigin.y, arrowSmallRadius, 3 * M_PI_2, 0, YES);
        CGPathCloseSubpath(arrowPath);
        _arrowLayer.path = arrowPath;
        [_arrowLayer setFillRule:kCAFillRuleEvenOdd];
        CGPathRelease(arrowPath);
        
        // Add the highlight shape
        
        CGMutablePathRef highlightPath = CGPathCreateMutable();
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y, currentTopRadius, 0, M_PI, YES);
        CGPathAddArc(highlightPath, NULL, topOrigin.x, topOrigin.y + 1.25, currentTopRadius, M_PI, 0, NO);
        
        _highlightLayer.path = highlightPath;
        [_highlightLayer setFillRule:kCAFillRuleNonZero];
        CGPathRelease(highlightPath);
        
    } else {
        // Start the shape disappearance animation
        
        CGFloat radius = lerp(kMinBottomRadius, kMaxBottomRadius, 0.2);
        CABasicAnimation *pathMorph = [CABasicAnimation animationWithKeyPath:@"path"];
        pathMorph.duration = 0.15;
        pathMorph.fillMode = kCAFillModeForwards;
        pathMorph.removedOnCompletion = NO;
        CGMutablePathRef toPath = CGPathCreateMutable();
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, 0, M_PI, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y);
        CGPathAddArc(toPath, NULL, topOrigin.x, topOrigin.y, radius, M_PI, 0, YES);
        CGPathAddCurveToPoint(toPath, NULL, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y);
        CGPathCloseSubpath(toPath);
        pathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:pathMorph forKey:nil];
        CABasicAnimation *shadowPathMorph = [CABasicAnimation animationWithKeyPath:@"shadowPath"];
        shadowPathMorph.duration = 0.15;
        shadowPathMorph.fillMode = kCAFillModeForwards;
        shadowPathMorph.removedOnCompletion = NO;
        shadowPathMorph.toValue = (__bridge id)toPath;
        [_shapeLayer addAnimation:shadowPathMorph forKey:nil];
        CGPathRelease(toPath);
        CABasicAnimation *shapeAlphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        shapeAlphaAnimation.duration = 0.1;
        shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1;
        shapeAlphaAnimation.toValue = [NSNumber numberWithFloat:0];
        shapeAlphaAnimation.fillMode = kCAFillModeForwards;
        shapeAlphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:shapeAlphaAnimation forKey:nil];
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.1;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        _activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        [CATransaction commit];
        [UIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveLinear animations:^{
            _activity.alpha = 1;
            _activity.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:nil];
        
        self.refreshing = YES;
        _canRefresh = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    CGPathRelease(path);
}

- (void)beginRefreshing
{
    if (!_refreshing) {
        CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        alphaAnimation.duration = 0.0001;
        alphaAnimation.toValue = [NSNumber numberWithFloat:0];
        alphaAnimation.fillMode = kCAFillModeForwards;
        alphaAnimation.removedOnCompletion = NO;
        [_shapeLayer addAnimation:alphaAnimation forKey:nil];
        [_arrowLayer addAnimation:alphaAnimation forKey:nil];
        [_highlightLayer addAnimation:alphaAnimation forKey:nil];
        
        _activity.alpha = 1;
        _activity.layer.transform = CATransform3DMakeScale(1, 1, 1);

        CGPoint offset = self.scrollView.contentOffset;
        _ignoreInset = YES;
        [self.scrollView setContentInset:UIEdgeInsetsMake(kOpenedViewHeight + self.originalContentInset.top, self.originalContentInset.left, self.originalContentInset.bottom, self.originalContentInset.right)];
        _ignoreInset = NO;
        [self.scrollView setContentOffset:offset animated:NO];

        self.refreshing = YES;
        _canRefresh = NO;
    }
}

- (void)endRefreshing
{
    if (_refreshing) {
        self.refreshing = NO;
        self.duringEnding = YES;
        // Create a temporary retain-cycle, so the scrollView won't be released
        // halfway through the end animation.
        // This allows for the refresh control to clean up the observer,
        // in the case the scrollView is released while the animation is running
        __block UIScrollView *blockScrollView = self.scrollView;
        [UIView animateWithDuration:0.4 animations:^{
            _ignoreInset = YES;
            [blockScrollView setContentInset:self.originalContentInset];
            _ignoreInset = NO;
            _activity.alpha = 0;
            _activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
        } completion:^(BOOL finished) {
            [_shapeLayer removeAllAnimations];
            _shapeLayer.path = nil;
            _shapeLayer.shadowPath = nil;
            _shapeLayer.position = CGPointZero;
            [_arrowLayer removeAllAnimations];
            _arrowLayer.path = nil;
            [_highlightLayer removeAllAnimations];
            _highlightLayer.path = nil;
            // We need to use the scrollView somehow in the end block,
            // or it'll get released in the animation block.
            _ignoreInset = YES;
            [blockScrollView setContentInset:self.originalContentInset];
            _ignoreInset = NO;
            self.duringEnding = NO;
        }];
    }
}

- (BOOL)isAnimating{
    return (self.refreshing || self.duringEnding);
}

@end
