//
//  EARestrictedScrollView.m
//
//  Copyright (c) 2015 Evgeny Aleksandrov. License: MIT.

#import "EARestrictedScrollView.h"

@interface EARestrictedScrollView ()

@property(nonatomic, strong) UIView *containerView;

@end

@implementation EARestrictedScrollView

#pragma mark - Subviews override

- (void)addSubview:(UIView *)view {
    if([self.subviews count] < 3 && [self checkIfScrollIndicator:view]) {
        [super addSubview:view];
    } else {
        [self.containerView addSubview:view];
    }
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    [self.containerView insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [self.containerView insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    [self.containerView insertSubview:view belowSubview:siblingSubview];
}

- (void)bringSubviewToFront:(UIView *)view {
    if(view.superview == self) {
        [super bringSubviewToFront:view];
    } else {
        [self.containerView bringSubviewToFront:view];
    }
}

- (void)sendSubviewToBack:(UIView *)view {
    [self.containerView sendSubviewToBack:view];
}

- (UIView *)viewWithTag:(NSInteger)tag {
    return [self.containerView viewWithTag:tag];
}

- (NSArray *)containedSubviews {
    return self.containerView.subviews;
}

#pragma mark - Private checks

- (BOOL)checkIfScrollIndicator:(UIView *)view {
    return ((self.showsHorizontalScrollIndicator && view.frame.size.height == 2.5f) || (self.showsVerticalScrollIndicator && view.frame.size.width == 2.5f)) && [view isKindOfClass:[UIImageView class]];
}

#pragma mark - Lazy properties

- (UIView *)containerView {
    if(!_containerView || ![_containerView superview]) {
        _containerView = [[UIView alloc] init];
        [super addSubview:_containerView];
    }
    
    return _containerView;
}

#pragma mark - Custom offset getters and setters

- (CGPoint)alignedContentOffset {
    CGPoint originalOffset = [super contentOffset];
    CGPoint newOffset = CGPointMake(originalOffset.x + self.restrictionArea.origin.x, originalOffset.y + self.restrictionArea.origin.y);
    
    return newOffset;
}

- (void)setAlignedContentOffset:(CGPoint)contentOffset {
    CGPoint newOffset = CGPointMake(contentOffset.x - self.restrictionArea.origin.x, contentOffset.y - self.restrictionArea.origin.y);
    
    [super setContentOffset:newOffset];
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    CGPoint newOffset = CGPointMake(contentOffset.x - self.restrictionArea.origin.x, contentOffset.y - self.restrictionArea.origin.y);
    
    [super setContentOffset:newOffset animated:animated];
}

- (void)setContentSize:(CGSize)contentSize {
    [self.containerView setFrame:CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y, contentSize.width, contentSize.height)];
    [self setRestrictionArea:CGRectMake(self.restrictionArea.origin.x, self.restrictionArea.origin.y, contentSize.width, contentSize.height)];
}

- (void)setRestrictionArea:(CGRect)restrictionArea {
    _restrictionArea = restrictionArea;
    
    if(CGRectEqualToRect(restrictionArea, CGRectZero)) {
        [super setContentOffset:CGPointMake([super contentOffset].x - self.containerView.frame.origin.x, [super contentOffset].y - self.containerView.frame.origin.y)];
        [self.containerView setFrame:CGRectMake(0.f, 0.f, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        [super setContentSize:CGSizeMake(self.containerView.frame.size.width, self.containerView.frame.size.height)];
    } else {
        CGPoint currentOffset = [super contentOffset];
        
        [self.containerView setFrame:CGRectMake(-restrictionArea.origin.x, -restrictionArea.origin.y, self.containerView.frame.size.width, self.containerView.frame.size.height)];
        [super setContentOffset:CGPointMake(currentOffset.x - restrictionArea.origin.x,currentOffset.y - restrictionArea.origin.y)];
        [super setContentSize:CGSizeMake(restrictionArea.size.width, restrictionArea.size.height)];
    }
}

@end
