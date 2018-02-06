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

+ (instancetype)startView{
    StartImage *st = [[StartImagesManager shareManager] randomImage];
    return [[self alloc] initWithStartImage:st];
}

- (instancetype)initWithStartImage:(StartImage *)st{
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        //add custom code
        UIColor *bgColor = [UIColor whiteColor];
        self.backgroundColor = bgColor;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 110 - kSafeArea_Bottom)];
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
        
        self.st = st;
    }
    return self;
}

- (void)setSt:(StartImage *)st{
    _st = st;
    UIImage *bgImage = [st.image scaleToSize:[_bgImageView doubleSizeOfFrame] usingMode:NYXResizeModeAspectFill];
    self.bgImageView.image = bgImage;
//    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.st.url]];
}

- (void)bgImageViewTapped{
    if ([BaseViewController presentingVC].navigationController.viewControllers.count <= 1) {
        NSString *linkStr = self.st.group.link;
        if ([linkStr hasPrefix:[NSObject baseURLStr]]) {
//            [BaseViewController presentLinkStr:linkStr];
            UIViewController *vc = [BaseViewController analyseVCFromLinkStr:linkStr] ?: [WebViewController webVCWithUrlStr:linkStr];
            [BaseViewController goToVC:vc];
        }
    }
}

- (void)startAnimationWithCompletionBlock:(void(^)(EaseStartView *easeStartView))completionHandler{
    [kKeyWindow addSubview:self];
    [kKeyWindow bringSubviewToFront:self];
    _bgImageView.alpha = 0.0;

    @weakify(self);
    [UIView animateWithDuration:1.0 animations:^{
        @strongify(self);
        self.bgImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.6 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                @strongify(self);
                [self setX:-kScreen_Width];
            } completion:^(BOOL finished) {
                @strongify(self);
                [self removeFromSuperview];
                if (completionHandler) {
                    completionHandler(self);
                }
            }];
        });
    }];
}

@end
