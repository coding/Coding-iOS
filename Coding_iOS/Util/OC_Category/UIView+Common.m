//
//  UIView+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-6.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIView+Common.h"
#define kTagBadgeView  1000
#define kTagBadgePointView  1001
#define kTagLineView 1007
#import <objc/runtime.h>

#import "Login.h"
#import "User.h"

@implementation UIView (Common)
static char LoadingViewKey, BlankPageViewKey;

@dynamic borderColor,borderWidth,cornerRadius, masksToBounds;

-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}

-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    [self.layer setCornerRadius:cornerRadius];
}

- (void)setMasksToBounds:(BOOL)masksToBounds{
    [self.layer setMasksToBounds:masksToBounds];
}

- (void)doCircleFrame{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
}
- (void)doNotCircleFrame{
    self.layer.cornerRadius = 0.0;
    self.layer.borderWidth = 0.0;
}

- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = width;
    if (!color) {
        self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
    }else{
        self.layer.borderColor = color.CGColor;
    }
}

- (UIViewController *)findViewController
{
    for (UIView* next = self; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

- (void)addBadgePoint:(NSInteger)pointRadius withPosition:(BadgePositionType)type {

    if(pointRadius < 1)
        return;
    
    [self removeBadgePoint];
    
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = kTagBadgePointView;
    badgeView.layer.cornerRadius = pointRadius;
    badgeView.backgroundColor = [UIColor redColor];
    
    switch (type) {
            
        case BadgePositionTypeMiddle:
            badgeView.frame = CGRectMake(0, self.frame.size.height / 2 - pointRadius, 2 * pointRadius, 2 * pointRadius);
            break;
            
        default:
            badgeView.frame = CGRectMake(self.frame.size.width - 2 * pointRadius, 0, 2 * pointRadius, 2 * pointRadius);
            break;
    }
    
    [self addSubview:badgeView];
}

- (void)addBadgePoint:(NSInteger)pointRadius withPointPosition:(CGPoint)point {

    if(pointRadius < 1)
        return;
    
    [self removeBadgePoint];
    
    UIView *badgeView = [[UIView alloc]init];
    badgeView.tag = kTagBadgePointView;
    badgeView.layer.cornerRadius = pointRadius;
    badgeView.backgroundColor = [UIColor colorWithHexString:@"0xf75388"];
    badgeView.frame = CGRectMake(0, 0, 2 * pointRadius, 2 * pointRadius);
    badgeView.center = point;
    [self addSubview:badgeView];
}

- (void)removeBadgePoint {

    for (UIView *subView in self.subviews) {
        
        if(subView.tag == kTagBadgePointView)
           [subView removeFromSuperview];
    }
}

- (void)addBadgeTip:(NSString *)badgeValue withCenterPosition:(CGPoint)center{
    if (!badgeValue || !badgeValue.length) {
        [self removeBadgeTips];
    }else{
        UIView *badgeV = [self viewWithTag:kTagBadgeView];
        if (badgeV && [badgeV isKindOfClass:[UIBadgeView class]]) {
            [(UIBadgeView *)badgeV setBadgeValue:badgeValue];
            badgeV.hidden = NO;
        }else{
            badgeV = [UIBadgeView viewWithBadgeTip:badgeValue];
            badgeV.tag = kTagBadgeView;
            [self addSubview:badgeV];
        }
        [badgeV setCenter:center];
    }
}
- (void)addBadgeTip:(NSString *)badgeValue{
    if (!badgeValue || !badgeValue.length) {
        [self removeBadgeTips];
    }else{
        UIView *badgeV = [self viewWithTag:kTagBadgeView];
        if (badgeV && [badgeV isKindOfClass:[UIBadgeView class]]) {
            [(UIBadgeView *)badgeV setBadgeValue:badgeValue];
        }else{
            badgeV = [UIBadgeView viewWithBadgeTip:badgeValue];
            badgeV.tag = kTagBadgeView;
            [self addSubview:badgeV];
        }
        CGSize badgeSize = badgeV.frame.size;
        CGSize selfSize = self.frame.size;
        CGFloat offset = 2.0;
        [badgeV setCenter:CGPointMake(selfSize.width- (offset+badgeSize.width/2),
                                      (offset +badgeSize.height/2))];
    }
}
- (void)removeBadgeTips{
    NSArray *subViews =[self subviews];
    if (subViews && [subViews count] > 0) {
        for (UIView *aView in subViews) {
            if (aView.tag == kTagBadgeView && [aView isKindOfClass:[UIBadgeView class]]) {
                aView.hidden = YES;
            }
        }
    }
}
- (void)setY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}
- (void)setX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}
- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}
- (void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}
- (void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}
- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size.width = size.width;
    frame.size.height = size.height;
    self.frame = frame;
}

- (CGFloat)maxXOfFrame{
    return CGRectGetMaxX(self.frame);
}

- (void)setSubScrollsToTop:(BOOL)scrollsToTop{
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)obj setScrollEnabled:scrollsToTop];
            *stop = YES;
        }
    }];
}

- (void)addGradientLayerWithColors:(NSArray *)cgColorArray{
    [self addGradientLayerWithColors:cgColorArray locations:nil startPoint:CGPointMake(0.0, 0.5) endPoint:CGPointMake(1.0, 0.5)];
}

- (void)addGradientLayerWithColors:(NSArray *)cgColorArray locations:(NSArray *)floatNumArray startPoint:(CGPoint )startPoint endPoint:(CGPoint)endPoint{
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = self.bounds;
    if (cgColorArray && [cgColorArray count] > 0) {
        layer.colors = cgColorArray;
    }else{
        return;
    }
    if (floatNumArray && [floatNumArray count] == [cgColorArray count]) {
        layer.locations = floatNumArray;
    }
    layer.startPoint = startPoint;
    layer.endPoint = endPoint;
    [self.layer addSublayer:layer];
}


+ (CGRect)frameWithOutNav{
    CGRect frame = kScreen_Bounds;
    frame.size.height -= (20+44);//减去状态栏、导航栏的高度
    return frame;
}

+ (UIViewAnimationOptions)animationOptionsForCurve:(UIViewAnimationCurve)curve
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
            break;
    }
    
    return kNilOptions;
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY{
    return [self lineViewWithPointYY:pointY andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color{
    return [self lineViewWithPointYY:pointY andColor:color andLeftSpace:0];
}

+ (UIView *)lineViewWithPointYY:(CGFloat)pointY andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(leftSpace, pointY, kScreen_Width - leftSpace, 0.5)];
    lineView.backgroundColor = color;
    return lineView;
}

+ (void)outputTreeInView:(UIView *)view withSeparatorCount:(NSInteger)count{
    NSString *outputStr = @"";
    outputStr = [outputStr stringByReplacingCharactersInRange:NSMakeRange(0, count) withString:@"-"];
    outputStr = [outputStr stringByAppendingString:view.description];
    printf("%s\n", outputStr.UTF8String);
    
    if (view.subviews.count == 0) {
        return;
    }else{
        count++;
        for (UIView *subV in view.subviews) {
            [self outputTreeInView:subV withSeparatorCount:count];
        }
    }
}

- (void)outputSubviewTree{
    [UIView outputTreeInView:self withSeparatorCount:0];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown{
    [self addLineUp:hasUp andDown:hasDown andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color{
    [self removeViewWithTag:kTagLineView];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color];
        upView.tag = kTagLineView;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds)-0.5 andColor:color];
        downView.tag = kTagLineView;
        [self addSubview:downView];
    }
    return [self addLineUp:hasUp andDown:hasDown andColor:color andLeftSpace:0];
}
- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color andLeftSpace:(CGFloat)leftSpace{
    [self removeViewWithTag:kTagLineView];
    if (hasUp) {
        UIView *upView = [UIView lineViewWithPointYY:0 andColor:color andLeftSpace:leftSpace];
        upView.tag = kTagLineView;
        [self addSubview:upView];
    }
    if (hasDown) {
        UIView *downView = [UIView lineViewWithPointYY:CGRectGetMaxY(self.bounds)-0.5 andColor:color andLeftSpace:leftSpace];
        downView.tag = kTagLineView;
        [self addSubview:downView];
    }
}
- (void)removeViewWithTag:(NSInteger)tag{
    for (UIView *aView in [self subviews]) {
        if (aView.tag == tag) {
            [aView removeFromSuperview];
        }
    }
}

- (void)addRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:cornerRadii];
    CAShapeLayer *maskLayer = [CAShapeLayer new];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (CGSize)doubleSizeOfFrame{
    CGSize size = self.frame.size;
    return CGSizeMake(size.width*2, size.height*2);
}
#pragma mark LoadingView
- (void)setLoadingView:(EaseLoadingView *)loadingView{
    [self willChangeValueForKey:@"LoadingViewKey"];
    objc_setAssociatedObject(self, &LoadingViewKey,
                             loadingView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"LoadingViewKey"];
}
- (EaseLoadingView *)loadingView{
    return objc_getAssociatedObject(self, &LoadingViewKey);
}

- (void)beginLoading{
    for (UIView *aView in [self.blankPageContainer subviews]) {
        if ([aView isKindOfClass:[EaseBlankPageView class]] && !aView.hidden) {
            return;
        }
    }
    
    if (!self.loadingView) { //初始化LoadingView
        self.loadingView = [[EaseLoadingView alloc] initWithFrame:self.bounds];
    }
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.self.edges.equalTo(self);
    }];
    [self.loadingView startAnimating];
}

- (void)endLoading{
    if (self.loadingView) {
        [self.loadingView stopAnimating];
    }
}

#pragma mark BlankPageView
- (void)setBlankPageView:(EaseBlankPageView *)blankPageView{
    [self willChangeValueForKey:@"BlankPageViewKey"];
    objc_setAssociatedObject(self, &BlankPageViewKey,
                             blankPageView,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"BlankPageViewKey"];
}

- (EaseBlankPageView *)blankPageView{
    return objc_getAssociatedObject(self, &BlankPageViewKey);
}

- (void)configBlankPage:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block{
    if (hasData) {
        if (self.blankPageView) {
            self.blankPageView.hidden = YES;
            [self.blankPageView removeFromSuperview];
        }
    }else{
        if (!self.blankPageView) {
            self.blankPageView = [[EaseBlankPageView alloc] initWithFrame:self.bounds];
        }
        self.blankPageView.hidden = NO;
        [self.blankPageContainer addSubview:self.blankPageView];

//        [self.blankPageContainer insertSubview:self.blankPageView atIndex:0];
//        [self.blankPageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.equalTo(self);
//            make.top.left.equalTo(self.blankPageContainer);
//        }];
        [self.blankPageView configWithType:blankPageType hasData:hasData hasError:hasError reloadButtonBlock:block];
    }
}

- (UIView *)blankPageContainer{
    UIView *blankPageContainer = self;
    for (UIView *aView in [self subviews]) {
        if ([aView isKindOfClass:[UITableView class]]) {
            blankPageContainer = aView;
        }
    }
    return blankPageContainer;
}

@end


@interface EaseLoadingView ()
@property (nonatomic, assign) CGFloat loopAngle, monkeyAlpha, angleStep, alphaStep;
@end


@implementation EaseLoadingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _loopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_loop"]];
        _monkeyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_monkey"]];
        [_loopView setCenter:self.center];
        [_monkeyView setCenter:self.center];
        [self addSubview:_loopView];
        [self addSubview:_monkeyView];
        [_loopView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        _loopAngle = 0.0;
        _monkeyAlpha = 1.0;
        _angleStep = 360/3;
        _alphaStep = 1.0/3.0;
    }
    return self;
}

- (void)startAnimating{
    self.hidden = NO;
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
    [self loadingAnimation];
}

- (void)stopAnimating{
    self.hidden = YES;
    _isLoading = NO;
}

- (void)loadingAnimation{
    static CGFloat duration = 0.25f;
    _loopAngle += _angleStep;
    if (_monkeyAlpha >= 1.0 || _monkeyAlpha <= 0.0) {
        _alphaStep = -_alphaStep;
    }
    _monkeyAlpha += _alphaStep;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        CGAffineTransform loopAngleTransform = CGAffineTransformMakeRotation(_loopAngle * (M_PI / 180.0f));
        _loopView.transform = loopAngleTransform;
        _monkeyView.alpha = _monkeyAlpha;
    } completion:^(BOOL finished) {
        if (_isLoading && [self superview] != nil) {
            [self loadingAnimation];
        }else{
            [self removeFromSuperview];

            _loopAngle = 0.0;
            _monkeyAlpha = 1,0;
            _alphaStep = ABS(_alphaStep);
            CGAffineTransform loopAngleTransform = CGAffineTransformMakeRotation(_loopAngle * (M_PI / 180.0f));
            _loopView.transform = loopAngleTransform;
            _monkeyView.alpha = _monkeyAlpha;
        }
    }];
}

@end

@implementation EaseBlankPageView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configWithType:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError reloadButtonBlock:(void (^)(id))block{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_loadAndShowStatusBlock) {
            _loadAndShowStatusBlock();
        }
    });
    
    
    if (hasData) {
        [self removeFromSuperview];
        return;
    }
    self.alpha = 1.0;
    //    图片
    if (!_monkeyView) {
        _monkeyView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:_monkeyView];
    }
    //    文字
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:15];
        _tipLabel.textColor = [UIColor lightGrayColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
    }
    
    //    布局
    [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_centerY);
    }];
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerX.equalTo(self);
        make.top.equalTo(_monkeyView.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    _reloadButtonBlock = nil;
    if (hasError) {
        //        加载失败
        if (!_reloadButton) {
            _reloadButton = [[UIButton alloc] initWithFrame:CGRectZero];
            [_reloadButton setImage:[UIImage imageNamed:@"blankpage_button_reload"] forState:UIControlStateNormal];
            _reloadButton.adjustsImageWhenHighlighted = YES;
            [_reloadButton addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_reloadButton];
            [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(_tipLabel.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(160, 60));
            }];
        }
        _reloadButton.hidden = NO;
        _reloadButtonBlock = block;
        [_monkeyView setImage:[UIImage imageNamed:@"blankpage_image_loadFail"]];
        _tipLabel.text = @"貌似出了点差错\n真忧伤呢";
    }else{
        //        空白数据
        if (_reloadButton) {
            _reloadButton.hidden = YES;
        }
        
        NSString *imageName, *tipStr;
        _curType=blankPageType;
        switch (blankPageType) {
            case EaseBlankPageTypeActivity://项目动态
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里还什么都没有\n赶快起来弄出一点动静吧";
            }
                break;
            case EaseBlankPageTypeTask://任务列表
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里还没有任务\n赶快起来为团队做点贡献吧";
            }
                break;
            case EaseBlankPageTypeTopic://讨论列表
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里怎么空空的\n发个讨论让它热闹点吧";
            }
                break;
            case EaseBlankPageTypeTweet://冒泡列表（自己的）
            {
                imageName = @"blankpage_image_Hi";
                tipStr = @"来，冒个泡吧～";
            }
                break;
            case EaseBlankPageTypeTweetOther://冒泡列表（别人的）
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这个人很懒\n一个冒泡都木有～";
            }
                break;
            case EaseBlankPageTypeProject://项目列表（自己的）
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProjectOther://项目列表（别人的）
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这个人很懒，一个项目都木有～";
            }
                break;
            case EaseBlankPageTypeFileDleted://去了文件页面，发现文件已经被删除了
            {
                imageName = @"blankpage_image_loadFail";
                tipStr = @"晚了一步\n文件刚刚被人删除了～";
            }
                break;
            case EaseBlankPageTypeFolderDleted://文件夹
            {
                imageName = @"blankpage_image_loadFail";
                tipStr = @"晚了一步\n文件夹貌似被人删除了～";
            }
                break;
            case EaseBlankPageTypePrivateMsg://私信列表
            {
                imageName = @"blankpage_image_Hi";
                tipStr = @"打个招呼吧～";
            }
                break;
            case EaseBlankPageTypeMyJoinedTopic://我参与的话题
            case EaseBlankPageTypeMyWatchedTopic://我关注的话题
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还没有话题呢～";
            }
                break;
            case EaseBlankPageTypeOthersJoinedTopic://ta参与的话题
            case EaseBlankPageTypeOthersWatchedTopic://ta关注的话题
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这个人很懒，一个话题都木有～";
            }
                break;
            case EaseBlankPageTypeFileTypeCannotSupport:
            {
                imageName = @"blankpage_image_loadFail";
                tipStr = @"不支持这种类型的文件\n试试右上角的按钮，用其他应用打开吧";
            }
                break;
            case EaseBlankPageTypeViewTips:
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里没有未读的消息";
            }
                break;
            case EaseBlankPageTypeShopOrders:
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有订单呢\n努力推代码，把洋葱猴带回家～";
            }
                break;
            case EaseBlankPageTypeShopSendOrders:
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有已发货的订单呢～";
            }
                break;
            case EaseBlankPageTypeShopUnSendOrders:
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有未发货的订单呢～";
            }
                break;
            case EaseBlankPageTypeNoExchangeGoods:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"还木有可兑换的商品呢\n努力推代码，把洋葱猴带回家～";
            }
                break;
            case EaseBlankPageTypeProject_ALL:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProject_CREATE:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProject_JOIN:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProject_WATCHED:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProject_STARED:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"您还木有项目呢，赶快起来创建吧～";
            }
                break;
            case EaseBlankPageTypeProject_SEARCH:{
                imageName = @"blankpage_image_Sleep";
                tipStr = @"什么都木有搜到，换个词再试试？";
            }
                break;
            default://其它页面（这里没有提到的页面，都属于其它）
            {
                imageName = @"blankpage_image_Sleep";
                tipStr = @"这里还什么都没有\n赶快起来弄出一点动静吧";
            }
                break;
        }
        [_monkeyView setImage:[UIImage imageNamed:imageName]];
        _tipLabel.text = tipStr;
        
        if ((blankPageType>=EaseBlankPageTypeProject_ALL)&&(blankPageType<=EaseBlankPageTypeProject_STARED)) {
            [_monkeyView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_centerY).offset(-35);
            }];
            
            //新增按钮
            UIButton *actionBtn=({
                UIButton *button=[UIButton new];
                button.backgroundColor=[UIColor colorWithHexString:@"0x3BBD79"];
                button.titleLabel.font=[UIFont systemFontOfSize:15];
                [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
                button.layer.cornerRadius=18;
                button.layer.masksToBounds=TRUE;
                button;
            });
            [self addSubview:actionBtn];
            
            [actionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(125 , 36));
                make.top.equalTo(_tipLabel.mas_bottom).offset(15);
                make.centerX.equalTo(self);
            }];
            
            NSString *titleStr;
            switch (blankPageType) {
                case EaseBlankPageTypeProject_ALL:
                case EaseBlankPageTypeProject_CREATE:
                case EaseBlankPageTypeProject_JOIN:
                    titleStr=@"+ 创建项目";
                    //                    [actionBtn setTitle:@"+ 创建项目" forState:UIControlStateNormal];
                    break;
                case EaseBlankPageTypeProject_WATCHED:
                    titleStr=@"+ 去关注";
                    //                    [actionBtn setTitle:@"+ 去关注" forState:UIControlStateNormal];
                    break;
                case EaseBlankPageTypeProject_STARED:
                    titleStr=@"+ 去收藏";
                    //                    [actionBtn setTitle:@"+去收藏" forState:UIControlStateNormal];
                    break;
                default:
                    break;
            }
            //            NSMutableAttributedString *titleFontStr=[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"+ %@",titleStr]];
            //            NSRange range;
            //            range.location=0;
            //            range.length=1;
            //            [titleFontStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:range];
            //            [actionBtn setAttributedTitle:titleFontStr forState:UIControlStateNormal];
            
            [actionBtn setTitle:titleStr forState:UIControlStateNormal];
            
        }
    }
}

- (void)reloadButtonClicked:(id)sender{
    self.hidden = YES;
    [self removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_reloadButtonBlock) {
            _reloadButtonBlock(sender);
        }
    });
}

-(void)btnAction{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_clickButtonBlock) {
            _clickButtonBlock(_curType);
        }
    });
}

@end

