//
//  MartFunctionTipView.m
//  CodingMart
//
//  Created by Ease on 16/8/12.
//  Copyright © 2016年 net.coding. All rights reserved.
//

#import "MartFunctionTipView.h"
#import <BlocksKit/BlocksKit+UIKit.h>

@interface MartFunctionTipView ()
@property (strong, nonatomic) UIImageView *imageV;
@property (strong, nonatomic) NSArray *imageNames;
@property (assign, nonatomic) NSUInteger curIndex;
@end

@implementation MartFunctionTipView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageV = [UIImageView new];
        _imageV.frame = self.frame = kScreen_Bounds;
        _imageV.backgroundColor = self.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageV];
        
        __weak typeof(self) weakSelf = self;;
        _imageV.userInteractionEnabled = YES;
        [_imageV bk_whenTapped:^{
            [weakSelf tapped];
        }];
    }
    return self;
}

- (void)tapped{
    _curIndex += 1;
    if (_imageNames.count > _curIndex) {
        _imageV.image = [UIImage imageNamed:_imageNames[_curIndex]];
    }else{
        [self dismiss];
    }
}

+ (void)showFunctionImages:(NSArray *)imageNames{
    if (kScreen_Height == 480) {//iPhone 4 的尺寸，忽略
        return;
    }
    if (imageNames.count <= 0) {
        return;
    }
    MartFunctionTipView *tipV = [MartFunctionTipView new];
    tipV.imageNames = imageNames;
    [tipV show];
}

+ (void)showFunctionImages:(NSArray *)imageNames onlyOneTime:(BOOL)onlyOneTime{
    if (kScreen_Height == 480) {//iPhone 4 的尺寸，忽略
        return;
    }
    if (imageNames.count <= 0) {
        return;
    }
    if (onlyOneTime) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *hasShowedImages = @[].mutableCopy;
        for (NSString *imageName in imageNames) {
            if ([defaults objectForKey:imageName]) {
                [hasShowedImages addObject:imageName];
            }else{
                [defaults setObject:@1 forKey:imageName];
            }
        }
        [defaults synchronize];
        NSMutableArray *needShowImages = imageNames.mutableCopy;
        [needShowImages removeObjectsInArray:hasShowedImages];
        imageNames = needShowImages;
    }
    [self showFunctionImages:imageNames];
}

- (void)show{
    if (_imageNames.count <= 0) {
        return;
    }
    _curIndex = 0;
    _imageV.image = [UIImage imageNamed:_imageNames[_curIndex]];
    [kKeyWindow addSubview:self];
}

- (void)dismiss{
    [self removeFromSuperview];
}
+ (AMPopTip *)showText:(NSString *)text direction:(AMPopTipDirection)direction bubbleOffset:(CGFloat)bubbleOffset inView:(UIView *)view fromFrame:(CGRect)frame dismissHandler:(void (^)())dismissHandler{
    AMPopTip *popTip = [AMPopTip popTip];
    popTip.shouldDismissOnTap = YES;
    popTip.font = [UIFont systemFontOfSize:15];
    popTip.radius = 4.0;
    popTip.arrowSize = CGSizeMake(10, 5);
    popTip.padding = 10;
    popTip.dismissHandler = dismissHandler;
//    popTip.popoverColor = [UIColor colorWithHexString:@"0x262728" andAlpha:0.8];
    popTip.popoverColor = kColorBrandGreen;
    popTip.bubbleOffset = bubbleOffset;
    [popTip showText:text direction:direction maxWidth:kScreen_Width - 30 inView:view fromFrame:frame duration:0];
    return popTip;
}
@end
