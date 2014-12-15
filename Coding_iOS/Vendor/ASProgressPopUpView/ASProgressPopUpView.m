//
//  ASProgressPopUpView.h
//  ASProgressPopUpView
//
//  Created by Alan Skipp on 19/10/2013.
//  Copyright (c) 2013 Alan Skipp. All rights reserved.
//

#import "ASPopUpView.h"
#import "ASProgressPopUpView.h"

@interface ASProgressPopUpView() <ASPopUpViewDelegate>
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) ASPopUpView *popUpView;
@end

@implementation ASProgressPopUpView
{
    CGSize _defaultPopUpViewSize; // size that fits string ‘100%’
    CGSize _popUpViewSize; // usually == _defaultPopUpViewSize, but can vary if dataSource is used
    UIColor *_popUpViewColor;
    NSArray *_keyTimes;
}

#pragma mark - initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - public

- (void)showPopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 1.0) return;
    
    [self.delegate progressViewWillDisplayPopUpView:self];
    [self.popUpView showAnimated:animated];
}

- (void)hidePopUpViewAnimated:(BOOL)animated
{
    if (self.popUpView.alpha == 0.0) return;
    
    [self.popUpView hideAnimated:animated completionBlock:^{
        if ([self.delegate respondsToSelector:@selector(progressViewDidHidePopUpView:)]) {
            [self.delegate progressViewDidHidePopUpView:self];
        }
    }];
}

- (void)setAutoAdjustTrackColor:(BOOL)autoAdjust
{
    if (_autoAdjustTrackColor == autoAdjust) return;
    
    _autoAdjustTrackColor = autoAdjust;
    
    // setProgressTintColor has been overridden to also set autoAdjustTrackColor to NO
    // therefore super's implementation must be called to set progressTintColor
    if (autoAdjust == NO) {
        super.progressTintColor = nil; // sets track to default blue color
    } else {
        super.progressTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setTextColor:(UIColor *)color
{
    _textColor = color;
    [self.popUpView setTextColor:color];
}

- (void)setFont:(UIFont *)font
{
    NSAssert(font, @"font can not be nil, it must be a valid UIFont");
    _font = font;
    [self.popUpView setFont:font];

    [self calculatePopUpViewSize];
}

// return the currently displayed color if possible, otherwise return _popUpViewColor
// if animated colors are set, the color will change each time the progress view updates
- (UIColor *)popUpViewColor
{
    return [self.popUpView color] ?: _popUpViewColor;
}

- (void)setPopUpViewColor:(UIColor *)popUpViewColor
{
    _popUpViewColor = popUpViewColor;
    _popUpViewAnimatedColors = nil; // animated colors should be discarded
    [self.popUpView setColor:popUpViewColor];

    if (_autoAdjustTrackColor) {
        super.progressTintColor = [self.popUpView opaqueColor];
    }
}

- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors
{
    [self setPopUpViewAnimatedColors:popUpViewAnimatedColors withPositions:nil];
}

// if 2 or more colors are present, set animated colors
// if only 1 color is present then call 'setPopUpViewColor:'
// if arg is nil then restore previous _popUpViewColor
- (void)setPopUpViewAnimatedColors:(NSArray *)popUpViewAnimatedColors withPositions:(NSArray *)positions
{
    if (positions) {
        NSAssert([popUpViewAnimatedColors count] == [positions count], @"popUpViewAnimatedColors and locations should contain the same number of items");
    }
    
    _popUpViewAnimatedColors = popUpViewAnimatedColors;
    _keyTimes = positions;
    
    if ([popUpViewAnimatedColors count] >= 2) {
        [self.popUpView setAnimatedColors:popUpViewAnimatedColors withKeyTimes:_keyTimes];
    } else {
        [self setPopUpViewColor:[popUpViewAnimatedColors lastObject] ?: _popUpViewColor];
    }
}

- (void)setPopUpViewCornerRadius:(CGFloat)popUpViewCornerRadius
{
    _popUpViewCornerRadius = popUpViewCornerRadius;
    [self.popUpView setCornerRadius:popUpViewCornerRadius];
}

- (void)setDataSource:(id<ASProgressPopUpViewDataSource>)dataSource
{
    _dataSource = dataSource;;
    [self calculatePopUpViewSize];
}

#pragma mark - ASPopUpViewDelegate

- (void)colorDidUpdate:(UIColor *)opaqueColor;
{
    super.progressTintColor = opaqueColor;
}

// returns the current progress in the range 0.0 – 1.0
- (CGFloat)currentValueOffset
{
    return self.progress;
}

#pragma mark - private

- (void)setup
{
    _autoAdjustTrackColor = YES;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    _numberFormatter = formatter;

    self.popUpView = [[ASPopUpView alloc] initWithFrame:CGRectZero];
    self.popUpViewColor = [UIColor colorWithHue:0.6 saturation:0.6 brightness:0.5 alpha:0.8];

    self.popUpViewCornerRadius = 4.0;
    self.popUpView.alpha = 0.0;
    self.popUpView.delegate = self;
    [self addSubview:self.popUpView];

    self.textColor = [UIColor whiteColor];
    self.font = [UIFont boldSystemFontOfSize:20.0f];
}

// ensure animation restarts if app is closed then becomes active again
- (void)didBecomeActiveNotification:(NSNotification *)note
{
    if (self.popUpViewAnimatedColors) {
        [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
    }
}

- (void)updatePopUpView
{
    NSString *progressString; // ask dataSource for string, if nil get string from _numberFormatter
    progressString = [self.dataSource progressView:self stringForProgress:self.progress] ?: [_numberFormatter stringFromNumber:@(self.progress)];
    if (progressString.length == 0) progressString = @"???"; // replacement for blank string
    
    // set _popUpViewSize to appropriate size for the progressString if required
    if ([self.dataSource respondsToSelector:@selector(progressViewShouldPreCalculatePopUpViewSize:)] &&
        [self.dataSource progressViewShouldPreCalculatePopUpViewSize:self] == NO)
    {
        if ([self.dataSource progressView:self stringForProgress:self.progress]) {
            _popUpViewSize = [self.popUpView popUpSizeForString:progressString];
        } else {
            _popUpViewSize = _defaultPopUpViewSize;
        }
    }
    
    // calculate the popUpView frame
    CGRect bounds = self.bounds;
    CGFloat xPos = (CGRectGetWidth(bounds) * self.progress) - _popUpViewSize.width/2;
    
    CGRect popUpRect = CGRectMake(xPos, CGRectGetMinY(bounds)-_popUpViewSize.height,
                                  _popUpViewSize.width, _popUpViewSize.height);
    
    // determine if popUpRect extends beyond the frame of the progress view
    // if so adjust frame and set the center offset of the PopUpView's arrow
    CGFloat minOffsetX = CGRectGetMinX(popUpRect);
    CGFloat maxOffsetX = CGRectGetMaxX(popUpRect) - CGRectGetWidth(bounds);
    
    CGFloat offset = minOffsetX < 0.0 ? minOffsetX : (maxOffsetX > 0.0 ? maxOffsetX : 0.0);
    popUpRect.origin.x -= offset;
    
    [self.popUpView setFrame:popUpRect arrowOffset:offset text:progressString];
}

- (void)calculatePopUpViewSize
{
    _defaultPopUpViewSize = [self.popUpView popUpSizeForString:[_numberFormatter stringFromNumber:@1.0]];;

    // if there isn't a dataSource, set _popUpViewSize to _defaultPopUpViewSize
    if (!self.dataSource) {
        _popUpViewSize = _defaultPopUpViewSize;
        return;
    }
    
    // if dataSource doesn't want popUpView size precalculated then return early from method
    if ([self.dataSource respondsToSelector:@selector(progressViewShouldPreCalculatePopUpViewSize:)]) {
        if ([self.dataSource progressViewShouldPreCalculatePopUpViewSize:self] == NO) return;
    }
    
    // calculate the largest popUpView size needed to keep the size consistent
    // ask the dataSource for values between 0.0 - 1.0 in 0.01 increments
    // set size to the largest width and height returned from the dataSource
    CGFloat width = 0.0, height = 0.0;
    for (int i=0; i<=100; i++) {
        NSString *string = [self.dataSource progressView:self stringForProgress:i/100.0];
        if (string) {
            CGSize size = [self.popUpView popUpSizeForString:string];
            if (size.width > width) width = size.width;
            if (size.height > height) height = size.height;
        }
    }
    _popUpViewSize = (width > 0.0 && height > 0.0) ? CGSizeMake(width, height) : _defaultPopUpViewSize;
}

#pragma mark - subclassed

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self updatePopUpView];
}

- (void)didMoveToWindow
{
    if (!self.window) { // removed from window - cancel observers and notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    else { // added to window - register observers, notifications and reset animated colors if needed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didBecomeActiveNotification:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        if (self.popUpViewAnimatedColors) {
            [self.popUpView setAnimatedColors:_popUpViewAnimatedColors withKeyTimes:_keyTimes];
        }
    }
}

- (void)setProgressTintColor:(UIColor *)color
{
    self.autoAdjustTrackColor = NO; // if a custom value is set then prevent auto coloring
    [super setProgressTintColor:color];
}

- (void)setProgress:(float)progress
{
    [super setProgress:progress];
    [self.popUpView setAnimationOffset:progress returnColor:^(UIColor *opaqueReturnColor) {
        super.progressTintColor = opaqueReturnColor;
    }];
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (animated) {
        [self.popUpView animateBlock:^(CFTimeInterval duration) {
            [UIView animateWithDuration:duration animations:^{
                [super setProgress:progress animated:animated];
                [self.popUpView setAnimationOffset:progress returnColor:^(UIColor *opaqueReturnColor) {
                    super.progressTintColor = opaqueReturnColor;
                }];
                [self layoutIfNeeded];
            }];
        }];
    } else {
        [super setProgress:progress animated:animated];
    }
}

@end
