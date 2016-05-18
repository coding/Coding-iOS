//
//  EaseInputTipsView.h
//  Coding_iOS
//
//  Created by Ease on 15/5/7.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EaseInputTipsViewType) {
    EaseInputTipsViewTypeLogin = 0,
    EaseInputTipsViewTypeRegister
};

@interface EaseInputTipsView : UIView
@property (strong, nonatomic) NSString *valueStr;
@property (nonatomic, assign, getter=isActive) BOOL active;
@property (nonatomic, assign, readonly) EaseInputTipsViewType type;

@property (nonatomic, copy) void(^selectedStringBlock)(NSString *);

+ (instancetype)tipsViewWithType:(EaseInputTipsViewType)type;
- (instancetype)initWithTipsType:(EaseInputTipsViewType)type;

- (void)refresh;

@end
