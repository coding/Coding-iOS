//
//  EaseStartView.m
//  Coding_iOS
//
//  Created by Ease on 14/12/26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "EaseStartView.h"
#import <NYXImagesKit/NYXImagesKit.h>
#import <Masonry/Masonry.h>

@interface EaseStartView ()
@property (strong, nonatomic) UIImageView *bgImageView, *logoIconView;
@property (strong, nonatomic) UILabel *descriptionStrLabel;
@end

@implementation EaseStartView

+ (instancetype)startViewWithBgImage:(UIImage *)bgImage descriptionStr:(NSString *)descriptionStr{
    UIImage *logoIcon = [UIImage imageNamed:@"logo_coding"];
    return [[self alloc] initWithBgImage:bgImage logoIcon:logoIcon descriptionStr:descriptionStr];
}

- (instancetype)initWithBgImage:(UIImage *)bgImage logoIcon:(UIImage *)logoIcon descriptionStr:(NSString *)descriptionStr{
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        //add custom code
        self.backgroundColor = [UIColor blackColor];
        UIColor *blackColor = [UIColor blackColor];
        [self addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.0].CGColor, (id)[blackColor colorWithAlphaComponent:0.7].CGColor] locations:nil startPoint:CGPointMake(0.5, 0.6) endPoint:CGPointMake(0.5, 1.0)];

        _bgImageView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.alpha = 0.0;
        [self addSubview:_bgImageView];
        _logoIconView = [[UIImageView alloc] init];
        _logoIconView.contentMode = UIViewContentModeScaleAspectFit;
        _logoIconView.alpha = 1.0;
        [self addSubview:_logoIconView];
        _descriptionStrLabel = [[UILabel alloc] init];
        _descriptionStrLabel.font = [UIFont systemFontOfSize:14];
        _descriptionStrLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
        _descriptionStrLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionStrLabel.alpha = 0.0;
        [self addSubview:_descriptionStrLabel];
        
        [_descriptionStrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@[self, _logoIconView]);
            make.height.mas_equalTo(20);
            make.bottom.equalTo(self.mas_bottom).offset(-30);
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
        }];
        
        [_logoIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_descriptionStrLabel.mas_top).offset(-40);
            make.size.mas_lessThanOrEqualTo(CGSizeMake(255, 60));
            make.left.equalTo(self.mas_left).offset(60);
            make.right.equalTo(self.mas_right).offset(-60);

        }];
        [self configWithBgImage:bgImage logoIcon:logoIcon descriptionStr:descriptionStr];
    }
    return self;
}

- (void)configWithBgImage:(UIImage *)bgImage logoIcon:(UIImage *)logoIcon descriptionStr:(NSString *)descriptionStr{
    UIImage *bgImage_resize = [bgImage scaleToSize:[_bgImageView doubleSizeOfFrame] usingMode:NYXResizeModeAspectFill];
    self.bgImageView.image = bgImage_resize? bgImage_resize: bgImage;
    self.logoIconView.image = logoIcon;
    self.descriptionStrLabel.text = descriptionStr;
    [self updateConstraintsIfNeeded];
}

- (void)startAnimationWithCompletionBlock:(void(^)(EaseStartView *easeStartView))completionHandler{
    [kKeyWindow addSubview:self];
    [kKeyWindow bringSubviewToFront:self];
    _bgImageView.alpha = 0.0;
    _logoIconView.alpha = 1.0;
    _descriptionStrLabel.alpha = 0.0;

    @weakify(self);
    [UIView animateWithDuration:2.0 animations:^{
        @strongify(self);
        self.bgImageView.alpha = 1.0;
        [self.bgImageView setFrame:CGRectMake(-kScreen_Width/20, -kScreen_Height/20, 1.1*kScreen_Width, 1.1*kScreen_Height)];
        self.descriptionStrLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            @strongify(self);
            self.bgImageView.alpha = 0.0;
            self.logoIconView.alpha = 0.0;
            self.descriptionStrLabel.alpha = 0.0;
            self.alpha = 0.0;
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
