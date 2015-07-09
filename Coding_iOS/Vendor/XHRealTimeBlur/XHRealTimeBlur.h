//
//  XHRealTimeBlur.h
//  XHRealTimeBlurExample
//
//  Created by 曾 宪华 on 14-9-7.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef void(^WillShowBlurViewBlcok)(void);
typedef void(^DidShowBlurViewBlcok)(BOOL finished);

typedef void(^WillDismissBlurViewBlcok)(void);
typedef void(^DidDismissBlurViewBlcok)(BOOL finished);


static NSString * const XHRealTimeBlurKey = @"XHRealTimeBlurKey";

static NSString * const XHRealTimeWillShowBlurViewBlcokBlcokKey = @"XHRealTimeWillShowBlurViewBlcokBlcokKey";
static NSString * const XHRealTimeDidShowBlurViewBlcokBlcokKey = @"XHRealTimeDidShowBlurViewBlcokBlcokKey";

static NSString * const XHRealTimeWillDismissBlurViewBlcokKey = @"XHRealTimeWillDismissBlurViewBlcokKey";
static NSString * const XHRealTimeDidDismissBlurViewBlcokKey = @"XHRealTimeDidDismissBlurViewBlcokKey";

typedef NS_ENUM(NSInteger, XHBlurStyle) {
    // 垂直梯度背景从黑色到半透明的。
    XHBlurStyleBlackGradient = 0,
    // 类似UIToolbar的半透明背景
    XHBlurStyleTranslucent,
    // 黑色半透明背景
    XHBlurStyleBlackTranslucent,
    // 纯白色
    XHBlurStyleWhite
};

@interface XHRealTimeBlur : UIView

/**
 *  Default is XHBlurStyleTranslucent
 */
@property (nonatomic, assign) XHBlurStyle blurStyle;

@property (nonatomic, assign) BOOL showed;

// Default is 0.3
@property (nonatomic, assign) NSTimeInterval showDuration;

// Default is 0.3
@property (nonatomic, assign) NSTimeInterval disMissDuration;

/**
 *  是否触发点击手势，默认关闭
 */
@property (nonatomic, assign) BOOL hasTapGestureEnable;

@property (nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
@property (nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;

@property (nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
@property (nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;


- (void)showBlurViewAtView:(UIView *)currentView;

- (void)showBlurViewAtViewController:(UIViewController *)currentViewContrller;

- (void)disMiss;

@end

@interface UIView (XHRealTimeBlur)

@property (nonatomic, copy) WillShowBlurViewBlcok willShowBlurViewcomplted;
@property (nonatomic, copy) DidShowBlurViewBlcok didShowBlurViewcompleted;


@property (nonatomic, copy) WillDismissBlurViewBlcok willDismissBlurViewCompleted;
@property (nonatomic, copy) DidDismissBlurViewBlcok didDismissBlurViewCompleted;

- (void)showRealTimeBlurWithBlurStyle:(XHBlurStyle)blurStyle;
- (void)showRealTimeBlurWithBlurStyle:(XHBlurStyle)blurStyle hasTapGestureEnable:(BOOL)hasTapGestureEnable;
- (void)disMissRealTimeBlur;

@end
