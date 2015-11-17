//
//  FRDLivelyButton.h.m
//  FRDLivelyButton.h
//
//  Created by Sebastien Windal on 2/24/14.
//  MIT license. See the LICENSE file distributed with this work.
//

#import "FRDLivelyButton.h"


NSString *const kFRDLivelyButtonHighlightScale = @"kFRDLivelyButtonHighlightScale";
NSString *const kFRDLivelyButtonLineWidth = @"kFRDLivelyButtonLineWidth";
NSString *const kFRDLivelyButtonColor = @"kFRDLivelyButtonColor";
NSString *const kFRDLivelyButtonHighlightedColor = @"kFRDLivelyButtonHighlightedColor";
NSString *const kFRDLivelyButtonHighlightAnimationDuration = @"kFRDLivelyButtonHighlightAnimationDuration";
NSString *const kFRDLivelyButtonUnHighlightAnimationDuration = @"kFRDLivelyButtonUnHighlightAnimationDuration";
NSString *const kFRDLivelyButtonStyleChangeAnimationDuration = @"kFRDLivelyButtonStyleChangeAnimationDuration";


@interface FRDLivelyButton()

@property (nonatomic) kFRDLivelyButtonStyle buttonStyle;
@property (nonatomic) CGFloat dimension;
@property (nonatomic) CGPoint offset;
@property (nonatomic) CGPoint centerPoint;

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) CAShapeLayer *line1Layer;
@property (nonatomic, strong) CAShapeLayer *line2Layer;
@property (nonatomic, strong) CAShapeLayer *line3Layer;

@property (nonatomic, strong) NSArray *shapeLayers;


@end

#define GOLDEN_RATIO 1.618

@implementation FRDLivelyButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInitializer];
    }
    return self;
}

-( id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

-(void) commonInitializer
{
    
    self.line1Layer = [[CAShapeLayer alloc] init];
    self.line2Layer = [[CAShapeLayer alloc] init];
    self.line3Layer = [[CAShapeLayer alloc] init];
    self.circleLayer = [[CAShapeLayer alloc] init];
    
    self.options = [FRDLivelyButton defaultOptions];
    
    [@[ self.line1Layer, self.line2Layer, self.line3Layer, self.circleLayer ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.anchorPoint = CGPointMake(0.0, 0.0);
        layer.lineJoin = kCALineJoinRound;
        layer.lineCap = kCALineCapRound;
        layer.contentsScale = self.layer.contentsScale;
        
        // initialize with an empty path so we can animate the path w/o having to check for NULLs. 
        CGPathRef dummyPath = CGPathCreateMutable();
        layer.path = dummyPath;
        CGPathRelease(dummyPath);

        [self.layer addSublayer:layer];
    }];
    
    
    [self addTarget:self action:@selector(showHighlight) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(showUnHighlight) forControlEvents:UIControlEventTouchUpOutside];
    
    // in case the button is not square, the offset will be use to keep our CGPath's centered in it.
    double  width   = CGRectGetWidth(self.frame) - (self.contentEdgeInsets.left + self.contentEdgeInsets.right);
    double  height  = CGRectGetHeight(self.frame) - (self.contentEdgeInsets.top + self.contentEdgeInsets.bottom);

    self.dimension = MIN(width, height);
    self.offset = CGPointMake((CGRectGetWidth(self.frame) - self.dimension) / 2.0f,
                              (CGRectGetHeight(self.frame) - self.dimension) / 2.0f);
    
    self.centerPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

-(void) setOptions:(NSDictionary *)options
{
    _options = options;
    
    [@[ self.line1Layer, self.line2Layer, self.line3Layer, self.circleLayer ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CAShapeLayer *layer = obj;
        layer.lineWidth = [[self valueForOptionKey:kFRDLivelyButtonLineWidth] floatValue];
        layer.strokeColor = [[self valueForOptionKey:kFRDLivelyButtonColor] CGColor];
    }];
}

-(id) valueForOptionKey:(NSString *)key
{
    if (self.options[key]) {
        return self.options[key];
    }
    return [FRDLivelyButton defaultOptions][key];
}

-(NSArray *) shapeLayers
{
    if (_shapeLayers == nil) {
        _shapeLayers = @[ self.circleLayer,
                          self.line1Layer,
                          self.line2Layer,
                          self.line3Layer ];
    }
    return _shapeLayers;
}

+(NSDictionary *) defaultOptions
{
    return @{
             kFRDLivelyButtonColor: [UIColor blackColor],
             kFRDLivelyButtonHighlightedColor: [UIColor lightGrayColor],
             kFRDLivelyButtonHighlightAnimationDuration: @(0.1),
             kFRDLivelyButtonHighlightScale: @(0.9),
             kFRDLivelyButtonLineWidth: @(1.0),
             kFRDLivelyButtonUnHighlightAnimationDuration: @(0.15),
             kFRDLivelyButtonStyleChangeAnimationDuration: @(0.3)
             };
}


-(CGAffineTransform) transformWithScale:(CGFloat)scale
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation((self.dimension + 2 * self.offset.x) * ((1-scale)/2.0f),
                                                                   (self.dimension + 2 * self.offset.y)  * ((1-scale)/2.0f));
    return CGAffineTransformScale(transform, scale, scale);
}

// you are responsible for releasing the return CGPath
-(CGPathRef) createCenteredCircleWithRadius:(CGFloat)radius
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.centerPoint.x + radius, self.centerPoint.y);
    // note: if clockwise is set to true, the circle will not draw on an actual device,
    // event hough it is fine on the simulator...
    CGPathAddArc(path, NULL, self.centerPoint.x, self.centerPoint.y, radius, 0, 2 * M_PI, false);
    
    return path;
}

// you are responsible for releasing the return CGPath
-(CGPathRef) createCenteredLineWithRadius:(CGFloat)radius angle:(CGFloat)angle offset:(CGPoint)offset
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    float c = cosf(angle);
    float s = sinf(angle);
    
    CGPathMoveToPoint(path, NULL,
                      self.centerPoint.x + offset.x + radius * c,
                      self.centerPoint.y + offset.y + radius * s);
    CGPathAddLineToPoint(path, NULL,
                         self.centerPoint.x + offset.x - radius * c,
                         self.centerPoint.y + offset.y - radius * s);
    
    return path;
}

-(CGPathRef) createLineFromPoint:(CGPoint)p1 toPoint:(CGPoint)p2
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, self.offset.x + p1.x, self.offset.y + p1.y);
    CGPathAddLineToPoint(path, NULL, self.offset.x + p2.x, self.offset.y + p2.y);
    
    return path;
}

-(void) setStyle:(kFRDLivelyButtonStyle)style animated:(BOOL)animated
{
    self.buttonStyle = style;
    
    CGPathRef newCirclePath = NULL;
    CGPathRef newLine1Path = NULL;
    CGPathRef newLine2Path = NULL;
    CGPathRef newLine3Path = NULL;
    
    CGFloat newCircleAlpha = 0.0f;
    CGFloat newLine1Alpha = 0.0f;
    
    // first compute the new paths for our 4 layers.
    if (style == kFRDLivelyButtonStyleHamburger) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, -self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else if (style == kFRDLivelyButtonStylePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_2 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        
    } else if (style == kFRDLivelyButtonStyleCirclePlus) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
        newCircleAlpha = 1.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:M_PI_2 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:0 offset:CGPointMake(0, 0)];
        
    } else if (style == kFRDLivelyButtonStyleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:-M_PI_4 offset:CGPointMake(0, 0)];
        
    } else if (style == kFRDLivelyButtonStyleCircleClose) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/2.0f];
        newCircleAlpha = 1.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:+M_PI_4 offset:CGPointMake(0, 0)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/2.0f/GOLDEN_RATIO angle:-M_PI_4 offset:CGPointMake(0, 0)];
    
    } else if (style == kFRDLivelyButtonStyleCaretUp) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];
        
    } else if (style == kFRDLivelyButtonStyleCaretDown) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(self.dimension/6.0f,0.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(-self.dimension/6.0f,0.0f)];

    } else if (style == kFRDLivelyButtonStyleCaretLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-3*M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:3*M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        
    } else if (style == kFRDLivelyButtonStyleCaretRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/20.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 0.0f;
        newLine2Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line2Layer.lineWidth/2.0f angle:-M_PI_4 offset:CGPointMake(0.0f,self.dimension/6.0f)];
        newLine3Path = [self createCenteredLineWithRadius:self.dimension/4.0f - self.line3Layer.lineWidth/2.0f angle:M_PI_4 offset:CGPointMake(0.0f,-self.dimension/6.0f)];
        
    } else if (style == kFRDLivelyButtonStyleArrowLeft) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:M_PI offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createLineFromPoint:CGPointMake(0, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else if (style == kFRDLivelyButtonStyleArrowRight) {
        newCirclePath = [self createCenteredCircleWithRadius:self.dimension/20.0f];
        newCircleAlpha = 0.0f;
        newLine1Path = [self createCenteredLineWithRadius:self.dimension/2.0f angle:0 offset:CGPointMake(0, 0)];
        newLine1Alpha = 1.0f;
        newLine2Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2+self.dimension/2.0f/GOLDEN_RATIO)];
        newLine3Path = [self createLineFromPoint:CGPointMake(self.dimension, self.dimension/2.0f)
                                         toPoint:CGPointMake(self.dimension - self.dimension/2.0f/GOLDEN_RATIO, self.dimension/2-self.dimension/2.0f/GOLDEN_RATIO)];
        
    } else {
        NSAssert(FALSE, @"unknown type");
    }
    
    NSTimeInterval duration = [[self valueForOptionKey:kFRDLivelyButtonStyleChangeAnimationDuration] floatValue];
    
    // animate all the layer path and opacity
    if (animated) {
        {
            CABasicAnimation *circleAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            circleAnim.removedOnCompletion = NO;
            circleAnim.duration = duration;
            circleAnim.fromValue = (__bridge id)self.circleLayer.path;
            circleAnim.toValue = (__bridge id)newCirclePath;
            [circleAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.circleLayer addAnimation:circleAnim forKey:@"animateCirclePath"];
        }
        {
            CABasicAnimation *circleAlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            circleAlphaAnim.removedOnCompletion = NO;
            circleAlphaAnim.duration = duration;
            circleAlphaAnim.fromValue = @(self.circleLayer.opacity);
            circleAlphaAnim.toValue = @(newCircleAlpha);
            [circleAlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.circleLayer addAnimation:circleAlphaAnim forKey:@"animateCircleOpacityPath"];
        }
        {
            CABasicAnimation *line1Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line1Anim.removedOnCompletion = NO;
            line1Anim.duration = duration;
            line1Anim.fromValue = (__bridge id)self.line1Layer.path;
            line1Anim.toValue = (__bridge id)newLine1Path;
            [line1Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line1Layer addAnimation:line1Anim forKey:@"animateLine1Path"];
        }
        {
            CABasicAnimation *line1AlphaAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
            line1AlphaAnim.removedOnCompletion = NO;
            line1AlphaAnim.duration = duration;
            line1AlphaAnim.fromValue = @(self.line1Layer.opacity);
            line1AlphaAnim.toValue = @(newLine1Alpha);
            [line1AlphaAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line1Layer addAnimation:line1AlphaAnim forKey:@"animateLine1OpacityPath"];
        }
        {
            CABasicAnimation *line2Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line2Anim.removedOnCompletion = NO;
            line2Anim.duration = duration;
            line2Anim.fromValue = (__bridge id)self.line2Layer.path;
            line2Anim.toValue = (__bridge id)newLine2Path;
            [line2Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line2Layer addAnimation:line2Anim forKey:@"animateLine2Path"];
        }
        {
            CABasicAnimation *line3Anim = [CABasicAnimation animationWithKeyPath:@"path"];
            line3Anim.removedOnCompletion = NO;
            line3Anim.duration = duration;
            line3Anim.fromValue = (__bridge id)self.line3Layer.path;
            line3Anim.toValue = (__bridge id)newLine3Path;
            [line3Anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [self.line3Layer addAnimation:line3Anim forKey:@"animateLine3Path"];
        }
    }
    
    self.circleLayer.path = newCirclePath;
    self.circleLayer.opacity = newCircleAlpha;
    self.line1Layer.path = newLine1Path;
    self.line1Layer.opacity = newLine1Alpha;
    self.line2Layer.path = newLine2Path;
    self.line3Layer.path = newLine3Path;

    CGPathRelease(newCirclePath);
    CGPathRelease(newLine1Path);
    CGPathRelease(newLine2Path);
    CGPathRelease(newLine3Path);
}

// animate button pressed event.
-(void) showHighlight
{
    float highlightScale = [[self valueForOptionKey:kFRDLivelyButtonHighlightScale] floatValue];
    
    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:kFRDLivelyButtonHighlightedColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        
        CGAffineTransform transform = [self transformWithScale:highlightScale];
        CGPathRef scaledPath =  CGPathCreateMutableCopyByTransformingPath(layer.path, &transform);
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:kFRDLivelyButtonHighlightAnimationDuration] floatValue];
        anim.removedOnCompletion = NO;
        anim.fromValue = (__bridge id) layer.path;
        anim.toValue = (__bridge id) scaledPath;
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [layer addAnimation:anim forKey:nil];
        
        layer.path = scaledPath;
        CGPathRelease(scaledPath);
    }];
}

// animate button release events i.e. touch up inside or outside.
-(void) showUnHighlight
{
    float unHighlightScale = 1/[[self valueForOptionKey:kFRDLivelyButtonHighlightScale] floatValue];

    [self.shapeLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj setStrokeColor:[[self valueForOptionKey:kFRDLivelyButtonColor] CGColor]];
        
        CAShapeLayer *layer = obj;
        CGPathRef path = layer.path;
        
        CGAffineTransform transform = [self transformWithScale:unHighlightScale];
        CGPathRef finalPath =  CGPathCreateMutableCopyByTransformingPath(path, &transform);
        
        CGAffineTransform uptransform = [self transformWithScale:unHighlightScale * 1.07];
        CGPathRef scaledUpPath = CGPathCreateMutableCopyByTransformingPath(path, &uptransform);
        
        CGAffineTransform downtransform = [self transformWithScale:unHighlightScale * 0.97];
        CGPathRef scaledDownPath = CGPathCreateMutableCopyByTransformingPath(path, &downtransform);
        
        NSArray *values = @[
                                (__bridge id) layer.path,
                                (id) CFBridgingRelease(scaledUpPath),
                                (id) CFBridgingRelease(scaledDownPath),
                                (__bridge id) finalPath
                           ];
        NSArray *times = @[ @(0.0), @(0.85), @(0.93), @(1.0) ];
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"path"];
        anim.duration = [[self valueForOptionKey:kFRDLivelyButtonUnHighlightAnimationDuration] floatValue];;
        
        anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        anim.removedOnCompletion = NO;

        anim.values = values;
        anim.keyTimes = times;
        
        [layer addAnimation:anim forKey:nil];
        
        layer.path = finalPath;
        CGPathRelease(finalPath);
    }];
    
    return;
}


-(void) dealloc
{
    for (CALayer* layer in [self.layer sublayers]) {
        [layer removeAllAnimations];
    }
    
    [self.layer removeAllAnimations];
    
    self.shapeLayers = nil;
}
@end
