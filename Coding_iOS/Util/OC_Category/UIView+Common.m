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
#import "YLImageView.h"
#import "YLGIFImage.h"

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
    self.layer.borderColor = kColorDDD.CGColor;
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
        self.layer.borderColor = kColorDDD.CGColor;
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
    return [self lineViewWithPointYY:pointY andColor:kColorDDD];
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
    [self addLineUp:hasUp andDown:hasDown andColor:kColorDDD];
}

- (void)addLineUp:(BOOL)hasUp andDown:(BOOL)hasDown andColor:(UIColor *)color{
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
    [self configBlankPage:blankPageType hasData:hasData hasError:hasError offsetY:0 reloadButtonBlock:block];
}

- (void)configBlankPage:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError offsetY:(CGFloat)offsetY reloadButtonBlock:(void(^)(id sender))block{
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
        [self.blankPageContainer insertSubview:self.blankPageView atIndex:0];
        [self.blankPageView configWithType:blankPageType hasData:hasData hasError:hasError offsetY:offsetY reloadButtonBlock:block];
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
        _monkeyView = [YLImageView new];
        _monkeyView.image = [YLGIFImage imageNamed:@"loading_monkey@2x.gif"];
        [self addSubview:_monkeyView];
        [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-30);
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];

//        _loopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_loop"]];
//        _monkeyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_monkey"]];
//        [_loopView setCenter:self.center];
//        [_monkeyView setCenter:self.center];
//        [self addSubview:_loopView];
//        [self addSubview:_monkeyView];
//        [_loopView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
//        [_monkeyView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
//        
//        _loopAngle = 0.0;
//        _monkeyAlpha = 1.0;
//        _angleStep = 360/3;
//        _alphaStep = 1.0/3.0;
    }
    return self;
}

- (void)startAnimating{
    self.hidden = NO;
    if (_isLoading) {
        return;
    }
    _isLoading = YES;
//    [self loadingAnimation];
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
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)configWithType:(EaseBlankPageType)blankPageType hasData:(BOOL)hasData hasError:(BOOL)hasError offsetY:(CGFloat)offsetY reloadButtonBlock:(void (^)(id))block{
    _curType = blankPageType;
    _reloadButtonBlock = block;

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
        _monkeyView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_monkeyView];
    }
    //    标题
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithHexString:@"0x425063"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    //    文字
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor clearColor];
        _tipLabel.numberOfLines = 0;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor colorWithHexString:@"0x76808E"];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
    }
    //    按钮
    if (!_actionButton) {//新增按钮
        _actionButton = ({
            UIButton *button = [UIButton new];
            button.backgroundColor = [UIColor colorWithHexString:@"0x425063"];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 4;
            button.layer.masksToBounds = YES;
            button;
        });
        [self addSubview:_actionButton];
    }
    if (!_reloadButton) {//重新加载按钮
        _reloadButton = ({
            UIButton *button = [UIButton new];
            button.backgroundColor = [UIColor colorWithHexString:@"0x425063"];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button addTarget:self action:@selector(reloadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.layer.cornerRadius = 4;
            button.layer.masksToBounds = YES;
            button;
        });
        [self addSubview:_reloadButton];
    }
    NSString *imageName, *titleStr, *tipStr;
    NSString *buttonTitle;
    if (hasError) {
        //        加载失败
        _actionButton.hidden = YES;

        tipStr = @"呀，网络出了问题";
        imageName = @"blankpage_image_LoadFail";
        buttonTitle = @"重新连接网络";
    }else{
        //        空白数据
        _reloadButton.hidden = YES;
        
        switch (_curType) {
            case EaseBlankPageTypeTaskResource: {
                tipStr = @"暂无关联资源";
            }
                break;
            case EaseBlankPageTypeActivity://项目动态
            {
                imageName = @"blankpage_image_Activity";
                tipStr = @"当前项目暂无相关动态";
            }
                break;
            case EaseBlankPageTypeTask://任务列表
            {
                imageName = @"blankpage_image_Task";
                tipStr = @"这里还没有任务哦";
            }
                break;
            case EaseBlankPageTypeTopic://讨论列表
            {
                imageName = @"blankpage_image_Topic";
                tipStr = @"这里还没有讨论哦";
            }
                break;
            case EaseBlankPageTypeTweet://冒泡列表（自己的）
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有发表过冒泡呢～";
            }
                break;
            case EaseBlankPageTypeTweetAction://冒泡列表（自己的）。有发冒泡的按钮
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有发表过冒泡呢～";
                buttonTitle = @"冒个泡吧";
            }
                break;
            case EaseBlankPageTypeTweetOther://冒泡列表（别人的）
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"这里还没有冒泡哦～";
            }
                break;
            case EaseBlankPageTypeTweetProject://冒泡列表（项目内的）
            {
                imageName = @"blankpage_image_Notice";
                tipStr = @"当前项目没有公告哦～";
            }
                break;
            case EaseBlankPageTypeProject://项目列表（自己的）
            {
                imageName = @"blankpage_image_Project";
                titleStr = @"欢迎来到 Coding";
                tipStr = @"协作从项目开始，赶快创建项目吧";
            }
                break;
            case EaseBlankPageTypeProjectOther://项目列表（别人的）
            {
                imageName = @"blankpage_image_Project";
                tipStr = @"这里还没有项目哦";
            }
                break;
            case EaseBlankPageTypeFileDleted://去了文件页面，发现文件已经被删除了
            {
                tipStr = @"晚了一步，此文件刚刚被人删除了～";
            }
                break;
            case EaseBlankPageTypeMRForbidden://去了MR页面，发现没有权限
            {
                tipStr = @"抱歉，请联系项目管理员进行代码权限设置";
            }
                break;
            case EaseBlankPageTypeFolderDleted://文件夹
            {
                tipStr = @"晚了一步，此文件夹刚刚被人删除了～";
            }
                break;
            case EaseBlankPageTypePrivateMsg://私信列表
            {
                imageName = @"";//就是空
                tipStr = @"";
            }
                break;
            case EaseBlankPageTypeMyJoinedTopic://我参与的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有参与过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeMyWatchedTopic://我关注的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"您还没有关注过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeOthersJoinedTopic://ta参与的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"Ta 还没有参与过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeOthersWatchedTopic://ta关注的话题
            {
                imageName = @"blankpage_image_Tweet";
                tipStr = @"Ta 还没有关注过话题讨论呢～";
            }
                break;
            case EaseBlankPageTypeFileTypeCannotSupport:
            {
                tipStr = @"还不支持查看此类型的文件呢";
            }
                break;
            case EaseBlankPageTypeViewTips:
            {
                imageName = @"blankpage_image_Tip";
                tipStr = @"您还没有收到通知哦";
            }
                break;
            case EaseBlankPageTypeShopOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"还没有订单记录～";
            }
                break;
            case EaseBlankPageTypeShopUnPayOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有待支付的订单记录～";
            }
                break;
            case EaseBlankPageTypeShopSendOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有已发货的订单记录～";
            }
                break;
            case EaseBlankPageTypeShopUnSendOrders:
            {
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"没有未发货的订单记录～";
            }
                break;
            case EaseBlankPageTypeNoExchangeGoods:{
                tipStr = @"还没有可兑换的商品呢～";
            }
                break;
            case EaseBlankPageTypeProject_ALL:
            case EaseBlankPageTypeProject_CREATE:
            case EaseBlankPageTypeProject_JOIN:{
                imageName = @"blankpage_image_Project";
                titleStr = @"欢迎来到 Coding";
                tipStr = @"协作从项目开始，赶快创建项目吧";
                buttonTitle=@"创建项目";
            }
                break;
            case EaseBlankPageTypeProject_WATCHED:{
                imageName = @"blankpage_image_Project";
                tipStr = @"您还没有关注过项目呢～";
                buttonTitle=@"去关注";
            }
                break;
            case EaseBlankPageTypeProject_STARED:{
                imageName = @"blankpage_image_Project";
                tipStr = @"您还没有收藏过项目呢～";
                buttonTitle=@"去收藏";
            }
                break;
            case EaseBlankPageTypeProject_SEARCH:{
                tipStr = @"什么都木有搜到，换个词再试试？";
            }
                break;
            case EaseBlankPageTypeTeam:{
                imageName = @"blankpage_image_Team";
                tipStr = @"您还没有参与过团队哦～";
            }
                break;
            case EaseBlankPageTypeFile:{
                imageName = @"blankpage_image_File";
                tipStr = @"这里还没有任何文件～";
            }
                break;
            case EaseBlankPageTypeMessageList:{
                imageName = @"blankpage_image_MessageList";
                tipStr = @"还没有新消息～";
            }
                break;
            case EaseBlankPageTypeViewPurchase:{
                imageName = @"blankpage_image_ShopOrder";
                tipStr = @"还没有订购记录～";
            }
                break;
            case EaseBlankPageTypeCode:
            {
                tipStr = @"当前项目还没有提交过代码呢～";
            }
                break;
            case EaseBlankPageTypeWiki:
            {
                tipStr = @"当前项目还没有创建 Wiki～";
            }
                break;
            default://其它页面（这里没有提到的页面，都属于其它）
            {
                tipStr = @"这里什么都没有～";
            }
                break;
        }
    }
    imageName = imageName ?: @"blankpage_image_Default";
    UIButton *bottomBtn = hasError? _reloadButton: _actionButton;
    _monkeyView.image = [UIImage imageNamed:imageName];
    _titleLabel.text = titleStr;
    _tipLabel.text = tipStr;
    [bottomBtn setTitle:buttonTitle forState:UIControlStateNormal];
    _titleLabel.hidden = titleStr.length <= 0;
    bottomBtn.hidden = buttonTitle.length <= 0;
    
    //    布局
    if (ABS(offsetY) > 0) {
        self.frame = CGRectMake(0, offsetY, self.width, self.height);
    }
    [_monkeyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        //            if (ABS(offsetY) > 1.0) {
        //                make.top.equalTo(self).offset(offsetY);
        //            }else{
        make.top.equalTo(self.mas_bottom).multipliedBy(0.15);
        //            }
        make.size.mas_equalTo(CGSizeMake(160, 160));
    }];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.top.equalTo(_monkeyView.mas_bottom);
    }];
    [_tipLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_titleLabel);
        if (titleStr.length > 0) {
            make.top.equalTo(_titleLabel.mas_bottom).offset(10);
        }else{
            make.top.equalTo(_monkeyView.mas_bottom);
        }
    }];
    if (buttonTitle.length > 0) {
        
    }
    [bottomBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(130, 44));
        make.top.equalTo(_tipLabel.mas_bottom).offset(25);
    }];
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

