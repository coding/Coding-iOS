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
    UIImage *logoIcon = [UIImage imageNamed:@"logo_coding"];
    StartImage *st = [[StartImagesManager shareManager] randomImage];
    return [[self alloc] initWithBgImage:st.image logoIcon:logoIcon descriptionStr:st.descriptionStr];
}

- (instancetype)initWithBgImage:(UIImage *)bgImage logoIcon:(UIImage *)logoIcon descriptionStr:(NSString *)descriptionStr{
    self = [super initWithFrame:kScreen_Bounds];
    if (self) {
        //add custom code
        self.backgroundColor = [UIColor colorWithHexString:@"0x131313"];
        UIColor *blackColor = [UIColor blackColor];

        _bgImageView = [[UIImageView alloc] initWithFrame:kScreen_Bounds];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.alpha = 0.0;
        [self addSubview:_bgImageView];
        
        [self addGradientLayerWithColors:@[(id)[blackColor colorWithAlphaComponent:0.0].CGColor, (id)[blackColor colorWithAlphaComponent:0.9].CGColor] locations:nil startPoint:CGPointMake(0.5, 0.6) endPoint:CGPointMake(0.5, 1.0)];

        _logoIconView = [[UIImageView alloc] init];
        _logoIconView.contentMode = UIViewContentModeScaleAspectFit;
        _logoIconView.alpha = 1.0;
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
            if (kDevice_Is_iPhone6Plus) {
                CGFloat scalePhysical = 414.0/1242;
                make.bottom.equalTo(self.mas_bottom).offset(-230*scalePhysical);
                make.left.equalTo(self.mas_left).offset(235*scalePhysical);
                make.right.equalTo(self.mas_right).offset(-235*scalePhysical);
            }else if (kDevice_Is_iPhone6){
                make.bottom.equalTo(self.mas_bottom).offset(-65);
                make.left.equalTo(self.mas_left).offset(69);
                make.right.equalTo(self.mas_right).offset(-69);
            }else{
                make.bottom.equalTo(self.mas_bottom).offset(-56);
                make.left.equalTo(self.mas_left).offset(60);
                make.right.equalTo(self.mas_right).offset(-60);
            }
            make.size.mas_lessThanOrEqualTo(CGSizeMake(255, 60));
            make.height.equalTo(_logoIconView.mas_width).multipliedBy(60.0/255.0);
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
    self.alpha = 1.0;

    @weakify(self);

    [UIView animateWithDuration:2.0 animations:^{
        @strongify(self);
        self.bgImageView.alpha = 1.0;
        [self.bgImageView setFrame:CGRectMake(-kScreen_Width/20, -kScreen_Height/20, 1.1*kScreen_Width, 1.1*kScreen_Height)];
        self.descriptionStrLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
