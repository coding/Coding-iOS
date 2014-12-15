//
//  ASPopUpView.m
//  ASProgressPopUpView
//
//  Created by Alan Skipp on 27/03/2014.
//  Copyright (c) 2014 Alan Skipp. All rights reserved.
//

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// This UIView subclass is used internally by ASProgressPopUpView
// The public API is declared in ASProgressPopUpView.h
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#import "ASPopUpView.h"

@implementation CALayer (ASAnimationAdditions)

- (void)animateKey:(NSString *)animationName fromValue:(id)fromValue toValue:(id)toValue
         customize:(void (^)(CABasicAnimation *animation))block
{
    [self setValue:toValue forKey:animationName];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:animationName];
    anim.fromValue = fromValue ?: [self.presentationLayer valueForKey:animationName];
    anim.toValue = toValue;
    if (block) block(anim);
    [self addAnimation:anim forKey:animationName];
}
@end

const float ARROW_LENGTH = 8.0;
const float POPUPVIEW_WIDTH_PAD = 1.15;
const float POPUPVIEW_HEIGHT_PAD = 1.1;

NSString *const FillColorAnimation = @"fillColor";

@implementation ASPopUpView
{
    BOOL _shouldAnimate;
    CFTimeInterval _animDuration;
    
    NSMutableAttributedString *_attributedString;
    CAShapeLayer *_pathLayer;

    CATextLayer *_textLayer;
    CGFloat _arrowCenterOffset;
    
    // never actually visible, its purpose is to interpolate color values for the popUpView color animation
    // using shape layer because it has a 'fillColor' property which is consistent with _backgroundLayer
    CAShapeLayer *_colorAnimLayer;
}

+ (Class)layerClass {
    return [CAShapeLayer class];
}

// if ivar _shouldAnimate) is YES then return an animation
// otherwise return NSNull (no animation)
- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if (_shouldAnimate) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
        anim.beginTime = CACurrentMediaTime();
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anim.fromValue = [layer.presentationLayer valueForKey:key];
        anim.duration = _animDuration;
        return anim;
    } else return (id <CAAction>)[NSNull null];
}

#pragma mark - public

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldAnimate = NO;
        self.layer.anchorPoint = CGPointMake(0.5, 1);
        
        self.userInteractionEnabled = NO;
        _pathLayer = (CAShapeLayer *)self.layer; // ivar can now be accessed without casting to CAShapeLayer every time
        
        _textLayer = [CATextLayer layer];
        _textLayer.alignmentMode = kCAAlignmentCenter;
        _textLayer.anchorPoint = CGPointMake(0, 0);
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        
        CABasicAnimation *defaultTextLayerAnim = [CABasicAnimation animation];
        defaultTextLayerAnim.duration = 0.25;
        _textLayer.actions = @{@"contents" : defaultTextLayerAnim};
        
        _colorAnimLayer = [CAShapeLayer layer];
        
        [self.layer addSublayer:_colorAnimLayer];
        [self.layer addSublayer:_textLayer];

        _attributedString = [[NSMutableAttributedString alloc] initWithString:@" " attributes:nil];
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)radius
{
    if (_cornerRadius == radius) return;
    _cornerRadius = radius;
    _pathLayer.path = [self pathForRect:self.bounds withArrowOffset:_arrowCenterOffset].CGPath;
}

- (UIColor *)color
{
    return [UIColor colorWithCGColor:[_pathLayer.presentationLayer fillColor]];
}

- (void)setColor:(UIColor *)color
{
    _pathLayer.fillColor = color.CGColor;
    [_colorAnimLayer removeAnimationForKey:FillColorAnimation]; // single color, no animation required
}

- (UIColor *)opaqueColor
{
    return opaqueUIColorFromCGColor([_colorAnimLayer.presentationLayer fillColor] ?: _pathLayer.fillColor);
}

- (void)setTextColor:(UIColor *)color
{
    _textLayer.foregroundColor = color.CGColor;
}

- (void)setFont:(UIFont *)font
{
    [_attributedString addAttribute:NSFontAttributeName
                              value:font
                              range:NSMakeRange(0, [_attributedString length])];
    
    _textLayer.font = (__bridge CFTypeRef)(font.fontName);
    _textLayer.fontSize = font.pointSize;
}

- (void)setText:(NSString *)string
{
    [[_attributedString mutableString] setString:string];
    _textLayer.string = string;
}

// set up an animation, but prevent it from running automatically
// the animation progress will be adjusted manually
- (void)setAnimatedColors:(NSArray *)animatedColors withKeyTimes:(NSArray *)keyTimes
{
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *col in animatedColors) {
        [cgColors addObject:(id)col.CGColor];
    }
    
    CAKeyframeAnimation *colorAnim = [CAKeyframeAnimation animationWithKeyPath:FillColorAnimation];
    colorAnim.keyTimes = keyTimes;
    colorAnim.values = cgColors;
    colorAnim.fillMode = kCAFillModeBoth;
    colorAnim.duration = 1.0;
    colorAnim.delegate = self;
    
    // As the interpolated color values from the presentationLayer are needed immediately
    // the animation must be allowed to start to initialize _colorAnimLayer's presentationLayer
    // hence the speed is set to min value - then set to zero in 'animationDidStart:' delegate method
    _colorAnimLayer.speed = FLT_MIN;
    _colorAnimLayer.timeOffset = 0.0;
    
    [_colorAnimLayer addAnimation:colorAnim forKey:FillColorAnimation];
}

- (void)setAnimationOffset:(CGFloat)animOffset returnColor:(void (^)(UIColor *opaqueReturnColor))block
{
    if ([_colorAnimLayer animationForKey:FillColorAnimation]) {
        _colorAnimLayer.timeOffset = animOffset;
        _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
        block([self opaqueColor]);
    }
}

- (void)setFrame:(CGRect)frame arrowOffset:(CGFloat)arrowOffset text:(NSString *)text
{
    // only redraw path if either the arrowOffset or popUpView size has changed
    if (arrowOffset != _arrowCenterOffset || !CGSizeEqualToSize(frame.size, self.frame.size)) {
        _pathLayer.path = [self pathForRect:frame withArrowOffset:arrowOffset].CGPath;
    }
    _arrowCenterOffset = arrowOffset;

    CGFloat anchorX = 0.5+(arrowOffset/CGRectGetWidth(frame));
    self.layer.anchorPoint = CGPointMake(anchorX, 1);
    self.layer.position = CGPointMake(CGRectGetMinX(frame) + CGRectGetWidth(frame)*anchorX, 0);
    self.layer.bounds = (CGRect){CGPointZero, frame.size};
    
    [self setText:text];
}

// _shouldAnimate = YES; causes 'actionForLayer:' to return an animation for layer property changes
// call the supplied block, then set _shouldAnimate back to NO
- (void)animateBlock:(void (^)(CFTimeInterval duration))block
{
    _shouldAnimate = YES;
    _animDuration = 0.5;
    
    CAAnimation *anim = [self.layer animationForKey:@"position"];
    if ((anim)) { // if previous animation hasn't finished reduce the time of new animation
        CFTimeInterval elapsedTime = MIN(CACurrentMediaTime() - anim.beginTime, anim.duration);
        _animDuration = _animDuration * elapsedTime / anim.duration;
    }
    
    block(_animDuration);
    _shouldAnimate = NO;
}

- (CGSize)popUpSizeForString:(NSString *)string
{
    [[_attributedString mutableString] setString:string];
    CGFloat w, h;
    w = ceilf([_attributedString size].width * POPUPVIEW_WIDTH_PAD);
    h = ceilf(([_attributedString size].height * POPUPVIEW_HEIGHT_PAD) + ARROW_LENGTH);
    return CGSizeMake(w, h);
}

- (void)showAnimated:(BOOL)animated
{
    if (!animated) {
        self.layer.opacity = 1.0;
        return;
    }
    
    [CATransaction begin]; {
        // start the transform animation from scale 0.5, or its current value if it's already running
        NSValue *fromValue = [self.layer animationForKey:@"transform"] ? [self.layer.presentationLayer valueForKey:@"transform"] : [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)];
        
        [self.layer animateKey:@"transform" fromValue:fromValue toValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]
                     customize:^(CABasicAnimation *animation) {
                         animation.duration = 0.6;
                         animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.8 :2.5 :0.35 :0.5];
         }];
        
        [self.layer animateKey:@"opacity" fromValue:nil toValue:@1.0 customize:^(CABasicAnimation *animation) {
            animation.duration = 0.1;
        }];
        
    } [CATransaction commit];
}

- (void)hideAnimated:(BOOL)animated completionBlock:(void (^)())block
{
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            block();
            self.layer.transform = CATransform3DIdentity;
        }];
        if (animated) {
            [self.layer animateKey:@"transform" fromValue:nil
                           toValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1)]
                         customize:^(CABasicAnimation *animation) {
                             animation.duration = 0.55;
                             animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.1 :-2 :0.3 :3];
                         }];
            
            [self.layer animateKey:@"opacity" fromValue:nil toValue:@0.0 customize:^(CABasicAnimation *animation) {
                animation.duration = 0.75;
            }];
        } else { // not animated - just set opacity to 0.0
            self.layer.opacity = 0.0;
        }
    } [CATransaction commit];
}

#pragma mark - CAAnimation delegate

// set the speed to zero to freeze the animation and set the offset to the correct value
// the animation can now be updated manually by explicity setting its 'timeOffset'
- (void)animationDidStart:(CAAnimation *)animation
{
    _colorAnimLayer.speed = 0.0;
    _colorAnimLayer.timeOffset = [self.delegate currentValueOffset];
    
    _pathLayer.fillColor = [_colorAnimLayer.presentationLayer fillColor];
    [self.delegate colorDidUpdate:[self opaqueColor]];
}

#pragma mark - private

- (UIBezierPath *)pathForRect:(CGRect)rect withArrowOffset:(CGFloat)arrowOffset;
{
    if (CGRectEqualToRect(rect, CGRectZero)) return nil;
    
    rect = (CGRect){CGPointZero, rect.size}; // ensure origin is CGPointZero

    // Create rounded rect
    CGRect roundedRect = rect;
    roundedRect.size.height -= ARROW_LENGTH;
    UIBezierPath *popUpPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:_cornerRadius];
    
    // Create arrow path
    CGFloat maxX = CGRectGetMaxX(roundedRect); // prevent arrow from extending beyond this point
    CGFloat arrowTipX = CGRectGetMidX(rect) + arrowOffset;
    CGPoint tip = CGPointMake(arrowTipX, CGRectGetMaxY(rect));
    
    CGFloat arrowLength = CGRectGetHeight(roundedRect)/2.0;
    CGFloat x = arrowLength * tan(45.0 * M_PI/180); // x = half the length of the base of the arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:tip];
    [arrowPath addLineToPoint:CGPointMake(MAX(arrowTipX - x, 0), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath addLineToPoint:CGPointMake(MIN(arrowTipX + x, maxX), CGRectGetMaxY(roundedRect) - arrowLength)];
    [arrowPath closePath];
    
    [popUpPath appendPath:arrowPath];
    
    return popUpPath;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat textHeight = [_attributedString size].height;
    CGRect textRect = CGRectMake(self.bounds.origin.x,
                                 (self.bounds.size.height-ARROW_LENGTH-textHeight)/2,
                                 self.bounds.size.width, textHeight);
    _textLayer.frame = CGRectIntegral(textRect);
}

static UIColor* opaqueUIColorFromCGColor(CGColorRef col)
{
    if (col == NULL) return nil;
    
    const CGFloat *components = CGColorGetComponents(col);
    UIColor *color;
    if (CGColorGetNumberOfComponents(col) == 2) {
        color = [UIColor colorWithWhite:components[0] alpha:1.0];
    } else {
        color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1.0];
    }
    return color;
}

@end
