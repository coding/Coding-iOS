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

@interface EaseStartView ()
@property (strong, nonatomic) UIImageView *bgImageView, *logoIconView;
@property (strong, nonatomic) UILabel *descriptionStrLabel;
@end

@implementation EaseStartView

+ (instancetype)startView{
    UIImage *logoIcon = [UIImage imageNamed:@"logo_coding_top"];
    StartImage *st = [[StartImagesManager shareManager] randomImage];
    return [[self alloc] initWithBgImage:st.image logoIcon:logoIcon descriptionStr:st.descriptionStr];
}

- (instancetype)initWithBgImage:(UIImage *)bgImage logoIcon:(UIImage *)logoIcon descriptionStr:(NSString *)descriptionStr{
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        //add custom code
        UIColor *blackColor = [UIColor blackColor];
        self.backgroundColor = blackColor;
        
        _bgImageView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.alpha = 0.0;
        [self addSubview:_bgImageView];
        if (![NSDate isDuringMidAutumn]) {
            [self addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.4].CGColor, (id)[blackColor colorWithAlphaComponent:0.0].CGColor] locations:nil startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 0.4)];
        }

        _logoIconView = [[UIImageView alloc] init];
        _logoIconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_logoIconView];
        _descriptionStrLabel = [[UILabel alloc] init];
        _descriptionStrLabel.font = [UIFont systemFontOfSize:10];
        _descriptionStrLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _descriptionStrLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionStrLabel.alpha = 0.0;
        [self addSubview:_descriptionStrLabel];
        
        [_descriptionStrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@[self, _logoIconView]);
            make.height.mas_equalTo(10);
            make.bottom.equalTo(self.mas_bottom).offset(-15);
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
        }];

        [_logoIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_equalTo(kScreen_Height/7);
            make.width.mas_equalTo(kScreen_Width *2/3);
            make.height.mas_equalTo(kScreen_Width/4 *2/3);
        }];
        
        [self configWithBgImage:bgImage logoIcon:logoIcon descriptionStr:descriptionStr];
    }
    return self;
}

- (void)configWithBgImage:(UIImage *)bgImage logoIcon:(UIImage *)logoIcon descriptionStr:(NSString *)descriptionStr{
    bgImage = [bgImage scaleToSize:[_bgImageView doubleSizeOfFrame] usingMode:NYXResizeModeAspectFill];
    self.bgImageView.image = bgImage;
    self.logoIconView.image = logoIcon;
    self.descriptionStrLabel.text = descriptionStr;
    [self updateConstraintsIfNeeded];
}

- (void)startAnimationWithCompletionBlock:(void(^)(EaseStartView *easeStartView))completionHandler{
    [kKeyWindow addSubview:self];
    [kKeyWindow bringSubviewToFront:self];
    _bgImageView.alpha = 0.0;
    _descriptionStrLabel.alpha = 0.0;

    @weakify(self);
    [UIView animateWithDuration:2.0 animations:^{
        @strongify(self);
        self.bgImageView.alpha = 1.0;
        self.descriptionStrLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.6 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            @strongify(self);
            [self setX:-kScreen_Width];
        } completion:^(BOOL finished) {
            @strongify(self);
            [self removeFromSuperview];
            if (completionHandler) {
                completionHandler(self);
            }
        }];
    }];
}

@end
