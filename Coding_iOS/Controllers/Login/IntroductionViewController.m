//
//  IntroductionViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/6/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//


#ifdef Target_Enterprise

#define kIntroductionView_AnimateDuration .6

#import "IntroductionViewController.h"
#import "LoginViewController.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "SMPageControl.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface IntroductionViewController ()
@property (strong, nonatomic) UIButton *loginEnterpriseBtn, *loginPrivateCloudBtn;
@property (strong, nonatomic) SMPageControl *pageControl;
@property (strong, nonatomic) IntroductionHomePage *homePage;
@property (strong, nonatomic) IntroductionIndexPage *indexPage;

@property (strong, nonatomic) NSMutableArray<IntroductionItem *> *pageItems;
@property (strong, nonatomic) IntroductionItem *curItem;
@end

@implementation IntroductionViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    {//Data
        _pageItems = @[].mutableCopy;
        IntroductionItem *homeItem = [IntroductionItem itemWithTitle:@"欢迎来到\nCoding Enterprise" content:@"CODING Enterprise 是 CODING 专为企业打造的软件开发协作平台，让企业更好地管理项目成员，便捷而深入地把握开发进度，让开发流程更高效。" imagePrefix:nil];
        homeItem.isHomePage = YES;
        [_pageItems addObject:homeItem];
        [_pageItems addObject:[IntroductionItem itemWithTitle:@"任务协作" content:@"任务进度与代码仓库无缝衔接" imagePrefix:@"intro_icon_task"]];
        [_pageItems addObject:[IntroductionItem itemWithTitle:@"文件管理" content:@"云端共享，支持在线预览、编辑、评论" imagePrefix:@"intro_icon_file"]];
        [_pageItems addObject:[IntroductionItem itemWithTitle:@"Wiki 知识库" content:@"文档书写，记录整个项目的来龙去脉" imagePrefix:@"intro_icon_wiki"]];
        [_pageItems addObject:[IntroductionItem itemWithTitle:@"代码托管" content:@"提交代码、合并请求一步到位" imagePrefix:@"intro_icon_code"]];
    }
    
    [self configureButtonsAndPageControl];
    self.curItem = _pageItems.firstObject;
    [self addGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)configureButtonsAndPageControl{
    //    PageControl
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_dot_light_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_dot_light_selected"];
    self.pageControl = ({
        SMPageControl *pageControl = [[SMPageControl alloc] init];
        pageControl.numberOfPages = self.pageItems.count;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorImage = pageIndicatorImage;
        pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
        [pageControl sizeToFit];
        pageControl.currentPage = 0;
        pageControl;
    });
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 20));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(kDevice_Use_iPhone4_Layout? -10: kDevice_Is_iPhone5? -30: -(50 + kSafeArea_Bottom));
    }];
    //    Button
    self.loginPrivateCloudBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loginPrivateCloudBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        [button setTitleColor:kColorDark2 forState:UIControlStateNormal];
        [button setTitle:@"私有部署账号登录" forState:UIControlStateNormal];
        [button doBorderWidth:1.0 color:kColorDark2 cornerRadius:2.0];
        button;
    });
    [self.view addSubview:self.loginPrivateCloudBtn];
    [self.loginPrivateCloudBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat padding = (MIN(kScreen_Width, 350) - 270)/ 2;
        make.height.mas_equalTo(56);
        make.left.equalTo(self.view).offset(padding);
        make.right.equalTo(self.view).offset(-padding);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(_pageControl.mas_top).offset(kDevice_Use_iPhone4_Layout? -10: kDevice_Is_iPhone5? -20 : -50);
    }];
    
    self.loginEnterpriseBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loginEnterpriseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = kColorDark4;
        button.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"企业账号登录" forState:UIControlStateNormal];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 2.0;
        button.hidden = true;
        button;
    });
    [self.view addSubview:self.loginEnterpriseBtn];
    [self.loginEnterpriseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.centerX.equalTo(self.loginPrivateCloudBtn);
        make.bottom.equalTo(self.loginPrivateCloudBtn.mas_top).offset(-10);
    }];
}

- (void)addGesture{
    {//Left
        UISwipeGestureRecognizer *swipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeG.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeG];
    }
    {//Right
        UISwipeGestureRecognizer *swipeG = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
        swipeG.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeG];
    }
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeG{
    if (swipeG.state == UIGestureRecognizerStateRecognized) {
        NSInteger index = [self.pageItems indexOfObject:self.curItem];
        if (index == NSNotFound) {
            index = 0;
        }else if (swipeG.direction & UISwipeGestureRecognizerDirectionLeft) {// +1
            index = MIN(++index, self.pageItems.count - 1);
        }else if (swipeG.direction & UISwipeGestureRecognizerDirectionRight){// - 1
            index = MAX(--index, 0);
        }
        self.curItem = self.pageItems[index];
    }
}

- (void)setCurItem:(IntroductionItem *)curItem{
    static BOOL isAnimating = NO;
    if (isAnimating) {
        return;
    }
    if (_curItem == curItem) {
        return;
    }
    BOOL isHomeOrIndexNeedChange = (_curItem.isHomePage != curItem.isHomePage);
    isAnimating = YES;
    YLGIFImage *preImage = (YLGIFImage *)[YLGIFImage imageNamed:[NSString stringWithFormat:@"%@_down.gif", _curItem.imagePrefix]];
    YLGIFImage *nextImage = (YLGIFImage *)[YLGIFImage imageNamed:[NSString stringWithFormat:@"%@_up.gif", curItem.imagePrefix]];
    NSTimeInterval animateDuration = preImage.totalDuration + nextImage.totalDuration;//这里有点傻，不过，就这样吧
    animateDuration += isHomeOrIndexNeedChange? kIntroductionView_AnimateDuration: 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isAnimating = NO;
    });
    
    _curItem = curItem;
    
    if (isHomeOrIndexNeedChange) {
        UIImage *pageIndicatorImage = [UIImage imageNamed:[NSString stringWithFormat:@"intro_dot_%@_unselected", _curItem.isHomePage? @"light": @"dark"]];
        UIImage *currentPageIndicatorImage = [UIImage imageNamed:[NSString stringWithFormat:@"intro_dot_%@_selected", _curItem.isHomePage? @"light": @"dark"]];
        _pageControl.pageIndicatorImage = pageIndicatorImage;
        _pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
    }
    self.homePage.curItem = self.indexPage.curItem = _curItem;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(preImage.totalDuration, kIntroductionView_AnimateDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pageControl.currentPage = [_pageItems indexOfObject:_curItem];
    });
}

- (IntroductionHomePage *)homePage{
    if (!_homePage) {
        _homePage = [IntroductionHomePage new];
        [self.view insertSubview:_homePage atIndex:0];
        [_homePage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _homePage;
}

- (IntroductionIndexPage *)indexPage{
    if (!_indexPage) {
        _indexPage = [IntroductionIndexPage new];
        [self.view insertSubview:_indexPage atIndex:0];
        [_indexPage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _indexPage;
}

#pragma mark Action
- (void)loginEnterpriseBtnClicked{
    [NSObject setupIsPrivateCloud:@(NO)];
    [self presentLoginAnimated:YES];
}

- (void)loginPrivateCloudBtnClicked{
    [NSObject setupIsPrivateCloud:@(YES)];
    [self presentLoginAnimated:YES];
}

- (void)presentLoginAnimated:(BOOL)animated{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:animated completion:nil];
}

- (void)presentLoginUI{
    [self presentLoginAnimated:NO];
}

@end

@interface IntroductionHomePage ()
@property (strong, nonatomic) UILabel *titleL, *contentL;
@property (strong, nonatomic) UIView *blurView;
@property (strong, nonatomic) NSMutableArray<UIView *> *circleList;
@end

@implementation IntroductionHomePage

- (instancetype)init{
    self = [super init];
    if (self) {
        self.alpha = 0;
        [self setupBlurView];
        _titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:30] textColor:kColorDark4];
        _contentL = [UILabel labelWithFont:[UIFont systemFontOfSize:kDevice_Is_iPhone6Plus? 17: 15] textColor:kColorDark4];
        _titleL.numberOfLines = _contentL.numberOfLines = 0;
        [self addSubview:_titleL];
        [self addSubview:_contentL];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(kDevice_Use_iPhone4_Layout? 64: 90);
            make.left.equalTo(self).offset(30);
            make.right.equalTo(self).offset(-30);
        }];
        [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_titleL);
            make.top.equalTo(_titleL.mas_bottom).offset((kDevice_Use_iPhone4_Layout || kDevice_Is_iPhone5)? 20: 40);
        }];
    }
    return self;
}

- (void)setupBlurView{
    for (NSInteger index = 0; index < 4; index++) {
        [self addCircleIndex:index];
    }
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
    [toolbar setBarStyle:UIBarStyleDefault];
    [self addSubview:toolbar];
    [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    _blurView = toolbar;
}

- (void)addCircleIndex:(NSInteger)index{
    static NSArray <UIColor *> *colorList;
    static NSArray <NSValue *> *pointList;
    if (!colorList) {//背景色列表
        CGFloat alpha = .9;
        colorList = @[
                      [UIColor colorWithHexString:@"0xC9F1DD" andAlpha:alpha],
                      [UIColor colorWithHexString:@"0x43CD87" andAlpha:alpha],
                      [UIColor colorWithHexString:@"0x76A6D9" andAlpha:alpha],
                      //                      [UIColor colorWithHexString:@"0x7991B2" andAlpha:alpha],
                      ];
    }
    if (!pointList) {//center 列表
        pointList = @[
                      [NSValue valueWithCGPoint:CGPointMake(kScreen_Width * .4, kScreen_Height * .2)],
                      [NSValue valueWithCGPoint:CGPointMake(kScreen_Width * .2, kScreen_Height * .6)],
                      [NSValue valueWithCGPoint:CGPointMake(kScreen_Width * .9, kScreen_Height * .5)],
                      //                      [NSValue valueWithCGPoint:CGPointMake(kScreen_Width * .7, kScreen_Height * .9)],
                      ];
    }
    if (index < 0 || index >= MIN(colorList.count, pointList.count)) {
        return;
    }
    if (!_circleList) {
        _circleList = @[].mutableCopy;
    }
    CGFloat circleWidth = kScreen_Width;
    UIView *circleV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, circleWidth, circleWidth)];
    circleV.backgroundColor = colorList[index];
    circleV.clipsToBounds = YES;
    circleV.layer.cornerRadius = circleWidth / 2;
    [self addSubview:circleV];
    [_circleList addObject:circleV];
    
    CGFloat animationWidth = kScreen_Width * .3;
    UIBezierPath *bezierPath = [UIBezierPath new];
    CGPoint originP = pointList[index].CGPointValue;
    originP.y += kScreen_Height * .4;
    [bezierPath moveToPoint:originP];
    [bezierPath addLineToPoint:CGPointMake(originP.x + animationWidth, originP.y)];
    [bezierPath addLineToPoint:CGPointMake(originP.x + animationWidth, originP.y + animationWidth)];
    [bezierPath addLineToPoint:CGPointMake(originP.x, originP.y + animationWidth)];
    [bezierPath addLineToPoint:CGPointMake(originP.x, originP.y)];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 15.0;
    animation.path = bezierPath.CGPath;
    animation.repeatCount = INFINITY;
    animation.timeOffset = ((CGFloat)index)/ (colorList.count) * animation.duration;
    [circleV.layer addAnimation:animation forKey:nil];
}

- (void)setCurItem:(IntroductionItem *)curItem{
    if (_curItem == curItem) {
        return;
    }
    if (!_curItem.isHomePage && !curItem.isHomePage) {
        _curItem = curItem;
    }else{
        YLGIFImage *preImage = (YLGIFImage *)[YLGIFImage imageNamed:[NSString stringWithFormat:@"%@_down.gif", _curItem.imagePrefix]];
        _curItem = curItem;
        if (_curItem.isHomePage) {
            _titleL.attributedText = self.attrTitle;
            _contentL.attributedText = self.attrContent;
        }
        CGFloat nextAlpha = _curItem.isHomePage? 1.0: 0;
        if (fabs(self.alpha - nextAlpha) > .1) {
            CGFloat circleDuration = .3;
            if (nextAlpha > .1) {
                self.alpha = nextAlpha;
                [UIView animateWithDuration:kIntroductionView_AnimateDuration - circleDuration delay:preImage.totalDuration options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    _titleL.alpha = _contentL.alpha = _blurView.alpha = nextAlpha;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:circleDuration animations:^{
                        [_circleList setValue:@(nextAlpha) forKey:@"alpha"];
                    }];
                }];
            }else{
                [UIView animateWithDuration:circleDuration animations:^{
                    [_circleList setValue:@(nextAlpha) forKey:@"alpha"];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:kIntroductionView_AnimateDuration - circleDuration animations:^{
                        _titleL.alpha = _contentL.alpha = _blurView.alpha = nextAlpha;
                    } completion:^(BOOL finished) {
                        self.alpha = nextAlpha;
                    }];
                }];
            }
        }
    }
}

- (NSAttributedString *)attrTitle{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_curItem.title];
    NSString *colorStr = [_curItem.title componentsSeparatedByString:@"\n"].lastObject;
    [attrStr addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:(kDevice_Use_iPhone4_Layout || kDevice_Is_iPhone5)? 30: 34],
                             NSForegroundColorAttributeName : kColorLightBlue}
                     range:[_curItem.title rangeOfString:colorStr]];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = 45;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [attrStr addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle}
                     range:NSMakeRange(0, _curItem.title.length)];
    return attrStr;
}

- (NSAttributedString *)attrContent{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:_curItem.content];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = 28;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    [attrStr addAttributes:@{NSParagraphStyleAttributeName : paragraphStyle}
                     range:NSMakeRange(0, _curItem.content.length)];
    return attrStr;
}

@end

@interface IntroductionIndexPage ()
@property (strong, nonatomic) UILabel *titleL, *contentL;
@property (strong, nonatomic) YLImageView *imageV;
@end

@implementation IntroductionIndexPage

- (instancetype)init{
    self = [super init];
    if (self) {
        self.alpha = 0;
        _imageV = [YLImageView new];
        _titleL = [UILabel labelWithFont:[UIFont systemFontOfSize:21 weight:UIFontWeightMedium] textColor:kColorDark4];
        _contentL = [UILabel labelWithFont:[UIFont systemFontOfSize:(kDevice_Use_iPhone4_Layout || kDevice_Is_iPhone5)? 15: 17] textColor:kColorDark4];
        [self addSubview:_imageV];
        [self addSubview:_titleL];
        [self addSubview:_contentL];
        [_imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(60);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake((462 / 2.0) * (kScreen_Height / 667), (390 / 2.0) * (kScreen_Height / 667)));
        }];
        [_titleL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageV.mas_bottom).offset(0);
            make.centerX.equalTo(self);
        }];
        [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleL.mas_bottom).offset(10);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (void)setCurItem:(IntroductionItem *)curItem{
    if (_curItem == curItem) {
        return;
    }
    YLGIFImage *preImage = (YLGIFImage *)[YLGIFImage imageNamed:[NSString stringWithFormat:@"%@_down.gif", _curItem.imagePrefix]];
    YLGIFImage *nextImage = (YLGIFImage *)[YLGIFImage imageNamed:[NSString stringWithFormat:@"%@_up.gif", curItem.imagePrefix]];
    preImage.loopCount = nextImage.loopCount = 1;
    BOOL isHomeOrIndexNeedChange = (_curItem.isHomePage != curItem.isHomePage);
    
    _curItem = curItem;
    
    if (isHomeOrIndexNeedChange) {//Index 和 Home Page 之间的切换
        YLGIFImage *gifImage = preImage ?: nextImage;
        CGFloat nextAlpha = _curItem.isHomePage? 0: 1.0;
        if (!_curItem.isHomePage) {
            _titleL.text = _curItem.title;
            _contentL.text = _curItem.content;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((nextAlpha > .1? kIntroductionView_AnimateDuration: 0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _imageV.image = gifImage;
        });
        [UIView animateWithDuration:gifImage.totalDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = nextAlpha;
        } completion:nil];
    }else{
        _imageV.image = preImage;
        [UIView animateWithDuration:preImage.totalDuration animations:^{
            _titleL.alpha = _contentL.alpha = 0;
        } completion:^(BOOL finished) {
            _imageV.image = nextImage;
            _titleL.text = _curItem.title;
            _contentL.text = _curItem.content;
            [UIView animateWithDuration:nextImage.totalDuration animations:^{
                _titleL.alpha = _contentL.alpha = 1.0;
            }];
        }];
    }
}

@end

@implementation IntroductionItem

+ (instancetype)itemWithTitle:(NSString *)title content:(NSString *)content imagePrefix:(NSString *)imagePrefix{
    IntroductionItem *item = [self new];
    item.title = title;
    item.content = content;
    item.imagePrefix = imagePrefix;
    return item;
}

@end

#else

#import "IntroductionViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

#import "SMPageControl.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface IntroductionViewController ()
@property (strong, nonatomic) UIButton *registerBtn, *loginBtn;
@property (strong, nonatomic) SMPageControl *pageControl;

@property (strong, nonatomic) NSMutableDictionary *iconsDict, *tipsDict;

@end

@implementation IntroductionViewController

- (instancetype)init
{
    if ((self = [super init])) {
        self.numberOfPages = 7;
        
        
        _iconsDict = [@{
                        @"0_image" : @"intro_icon_6",
                        @"1_image" : @"intro_icon_0",
                        @"2_image" : @"intro_icon_1",
                        @"3_image" : @"intro_icon_2",
                        @"4_image" : @"intro_icon_3",
                        @"5_image" : @"intro_icon_4",
                        @"6_image" : @"intro_icon_5",
                        } mutableCopy];
        _tipsDict = [@{
                       @"1_image" : @"intro_tip_0",
                       @"2_image" : @"intro_tip_1",
                       @"3_image" : @"intro_tip_2",
                       @"4_image" : @"intro_tip_3",
                       @"5_image" : @"intro_tip_4",
                       @"6_image" : @"intro_tip_5",
                       } mutableCopy];
        
        //        _iconsDict = [NSMutableDictionary new];
        //        _tipsDict = [NSMutableDictionary new];
        //        for (int i = 0; i < self.numberOfPages; i++) {
        //            NSString *imageKey = [self imageKeyForIndex:i];
        //            [_iconsDict setObject:[NSString stringWithFormat:@"intro_icon_%d", i] forKey:imageKey];
        //            [_tipsDict setObject:[NSString stringWithFormat:@"intro_tip_%d", i] forKey:imageKey];
        //        }
    }
    
    return self;
}

- (NSString *)imageKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_image", (long)index];
}

- (NSString *)viewKeyForIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%ld_view", (long)index];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
    
    [self configureViews];
    [self configureAnimations];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - Orientations
- (BOOL)shouldAutorotate{
    return UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication.statusBarOrientation);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)forceChangeToOrientation:(UIInterfaceOrientation)interfaceOrientation{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:interfaceOrientation] forKey:@"orientation"];
}

#pragma mark Super
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self animateCurrentFrame];
    NSInteger nearestPage = floorf(self.pageOffset + 0.5);
    self.pageControl.currentPage = nearestPage;
}

#pragma Views
- (void)configureViews{
    [self configureButtonsAndPageControl];
    
    CGFloat scaleFactor = 1.0;
    CGFloat desginHeight = 667.0;//iPhone6 的设计尺寸
    if (!kDevice_Is_iPhone6 && !kDevice_Is_iPhone6Plus && !kDevice_Is_FullScreen) {
        scaleFactor = kScreen_Height/desginHeight;
    }
    
    for (int i = 0; i < self.numberOfPages; i++) {
        NSString *imageKey = [self imageKeyForIndex:i];
        NSString *viewKey = [self viewKeyForIndex:i];
        NSString *iconImageName = [self.iconsDict objectForKey:imageKey];
        NSString *tipImageName = [self.tipsDict objectForKey:imageKey];
        
        if (iconImageName) {
            UIImage *iconImage = [UIImage imageNamed:iconImageName];
            if (iconImage) {
                iconImage = scaleFactor != 1.0? [iconImage scaleByFactor:scaleFactor] : iconImage;
                UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
                [self.contentView addSubview:iconView];
                [self.iconsDict setObject:iconView forKey:viewKey];
            }
        }
        
        if (tipImageName) {
            UIImage *tipImage = [UIImage imageNamed:tipImageName];
            if (tipImage) {
                tipImage = scaleFactor != 1.0? [tipImage scaleByFactor:scaleFactor]: tipImage;
                UIImageView *tipView = [[UIImageView alloc] initWithImage:tipImage];
                [self.contentView addSubview:tipView];
                [self.tipsDict setObject:tipView forKey:viewKey];
            }
        }
    }
}

- (void)configureButtonsAndPageControl{
    //    Button
    UIColor *darkColor = kColorBrandBlue;
    CGFloat buttonWidth = kScreen_Width * 0.4;
    CGFloat buttonHeight = kScaleFrom_iPhone5_Desgin(38);
    CGFloat paddingToCenter = kScaleFrom_iPhone5_Desgin(10);
    CGFloat paddingToBottom = kScaleFrom_iPhone5_Desgin(20) + kSafeArea_Bottom;
    
    self.registerBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(registerBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = darkColor;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:@"注册" forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button;
    });
    self.loginBtn = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [button setTitleColor:darkColor forState:UIControlStateNormal];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = buttonHeight/2;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = darkColor.CGColor;
        button;
    });
    
    [self.view addSubview:self.registerBtn];
    [self.view addSubview:self.loginBtn];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        make.right.equalTo(self.view.mas_centerX).offset(-paddingToCenter);
        make.bottom.equalTo(self.view).offset(-paddingToBottom);
    }];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(buttonWidth, buttonHeight));
        make.left.equalTo(self.view.mas_centerX).offset(paddingToCenter);
        make.bottom.equalTo(self.view).offset(-paddingToBottom);
    }];
    
    //    PageControl
    UIImage *pageIndicatorImage = [UIImage imageNamed:@"intro_dot_unselected"];
    UIImage *currentPageIndicatorImage = [UIImage imageNamed:@"intro_dot_selected"];
    
    if (!kDevice_Is_iPhone6 && !kDevice_Is_iPhone6Plus) {
        CGFloat desginWidth = 375.0;//iPhone6 的设计尺寸
        CGFloat scaleFactor = kScreen_Width/desginWidth;
        pageIndicatorImage = [pageIndicatorImage scaleByFactor:scaleFactor];
        currentPageIndicatorImage = [currentPageIndicatorImage scaleByFactor:scaleFactor];
    }
    
    self.pageControl = ({
        SMPageControl *pageControl = [[SMPageControl alloc] init];
        pageControl.numberOfPages = self.numberOfPages;
        pageControl.userInteractionEnabled = NO;
        pageControl.pageIndicatorImage = pageIndicatorImage;
        pageControl.currentPageIndicatorImage = currentPageIndicatorImage;
        [pageControl sizeToFit];
        pageControl.currentPage = 0;
        pageControl;
    });
    
    [self.view addSubview:self.pageControl];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, kScaleFrom_iPhone5_Desgin(20)));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.registerBtn.mas_top).offset(-kScaleFrom_iPhone5_Desgin(20));
    }];
}


#pragma mark Animations
- (void)configureAnimations{
    [self configureTipAndTitleViewAnimations];
}

- (void)configureTipAndTitleViewAnimations{
    for (int index = 0; index < self.numberOfPages; index++) {
        NSString *viewKey = [self viewKeyForIndex:index];
        UIView *iconView = [self.iconsDict objectForKey:viewKey];
        UIView *tipView = [self.tipsDict objectForKey:viewKey];
        if (iconView) {
            if (index == 0) {
                [self keepView:iconView onPages:@[@(index +1), @(index)] atTimes:@[@(index - 1), @(index)]];
                
                [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(kScreen_Height/7);
                }];
            }else{
                [self keepView:iconView onPage:index];
                
                [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(-kScreen_Height/6);
                }];
            }
            IFTTTAlphaAnimation *iconAlphaAnimation = [IFTTTAlphaAnimation animationWithView:iconView];
            [iconAlphaAnimation addKeyframeForTime:index -0.5 alpha:0.f];
            [iconAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [iconAlphaAnimation addKeyframeForTime:index +0.5 alpha:0.f];
            [self.animator addAnimation:iconAlphaAnimation];
        }
        if (tipView) {
            [self keepView:tipView onPages:@[@(index +1), @(index), @(index-1)] atTimes:@[@(index - 1), @(index), @(index +1)]];
            
            IFTTTAlphaAnimation *tipAlphaAnimation = [IFTTTAlphaAnimation animationWithView:tipView];
            [tipAlphaAnimation addKeyframeForTime:index -0.5 alpha:0.f];
            [tipAlphaAnimation addKeyframeForTime:index alpha:1.f];
            [tipAlphaAnimation addKeyframeForTime:index +0.5 alpha:0.f];
            [self.animator addAnimation:tipAlphaAnimation];
            
            [tipView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(iconView.mas_bottom).offset(kScaleFrom_iPhone5_Desgin(45));
            }];
        }
    }
}


#pragma mark Action
- (void)registerBtnClicked{
    RegisterViewController *vc = [RegisterViewController vcWithMethodType:RegisterMethodPhone registerObj:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)loginBtnClicked{
    LoginViewController *vc = [[LoginViewController alloc] init];
    vc.showDismissButton = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

@end

#endif

