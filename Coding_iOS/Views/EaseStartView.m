//
//  EaseStartView.m
//  Coding_iOS
//
//  Created by Ease on 14/12/26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "EaseStartView.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import "StartImagesManager.h"

#import "WebViewController.h"

@interface EaseStartView ()
@property (strong, nonatomic) UIImageView *bgImageView, *logoIconView;
@property (strong, nonatomic) StartImage *st;
@end

@implementation EaseStartView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.frame = kScreen_Bounds;
        //add custom code
        UIColor *bgColor = [UIColor whiteColor];
        self.backgroundColor = bgColor;
        
        _bgImageView = [[YLImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 110 - kSafeArea_Bottom)];
        _bgImageView.clipsToBounds = YES;
        _bgImageView.alpha = 0.0;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_bgImageView];
        
        _logoIconView = [[UIImageView alloc] init];
        _logoIconView.contentMode = UIViewContentModeScaleAspectFill;
        _logoIconView.image = [UIImage imageNamed:@"logo_coding"];
        [self addSubview:_logoIconView];
        [_logoIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self.mas_bottom).offset(-55 - kSafeArea_Bottom);
            make.size.mas_equalTo(CGSizeMake(65, 65));
        }];
        
        __weak typeof(self) weakSelf = self;
        _bgImageView.userInteractionEnabled = YES;
        [_bgImageView bk_whenTapped:^{
            [weakSelf bgImageViewTapped];
        }];
    }
    return self;
}

- (void)setSt:(StartImage *)st{
    _st = st;
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.st.url]];
    DebugLog(@"setSt : ---- %@", st.url);
}

- (void)bgImageViewTapped{
    if ([BaseViewController presentingVC].navigationController.viewControllers.count <= 1) {
        NSString *linkStr = self.st.group.link;
        UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr] ?: [WebViewController webVCWithUrlStr:linkStr];
        [BaseViewController goToVC:vc];
    }
}

- (void)startAnimationWithCompletionBlock:(void(^)(EaseStartView *easeStartView))completionHandler{
    __weak typeof(self) weakSelf = self;
    //加载数据 st
    [[StartImagesManager shareManager] refreshImagesBlock:^(NSArray<StartImage *> *images, NSError *error) {
        if (images.count > 0) {
            NSInteger index = arc4random() % images.count;
            weakSelf.st = images[index];
        }
    }];
    
    [kKeyWindow addSubview:self];
    [kKeyWindow bringSubviewToFront:self];
    _bgImageView.alpha = 0.0;
    
    [UIView animateWithDuration:1.0 animations:^{
        weakSelf.bgImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (!weakSelf.st) {//此时若 st 还未加载到，则省去展示停顿时间
            [UIView animateWithDuration:.3 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                weakSelf.alpha = .0;
            } completion:^(BOOL finished) {
                [weakSelf p_animationCompletedWithBlock:completionHandler];
            }];
        }else{//若 st 数据已加载，停留展示，然后消失
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.6 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    weakSelf.x = -kScreen_Width;
                } completion:^(BOOL finished) {
                    [weakSelf p_animationCompletedWithBlock:completionHandler];
                }];
            });
        }
    }];
}

- (void)p_animationCompletedWithBlock:(void(^)(EaseStartView *easeStartView))completionHandler{
    [self removeFromSuperview];
    if (completionHandler) {
        completionHandler(self);
    }
}

@end
