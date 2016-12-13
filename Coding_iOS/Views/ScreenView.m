//
//  ScreenView.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/7.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "ScreenView.h"


@interface ScreenView ()

@end

@implementation ScreenView

#pragma mark - 生命周期方法

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatView];
    }
    return self;
}


#pragma mark - 外部方法

+ (instancetype)creat {
    ScreenView *screenView = [[ScreenView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64)];
    screenView.hidden = YES;
    [kKeyWindow addSubview:screenView];
    
    return screenView;
}

- (void)showOrHide {
    self.hidden = !self.hidden;
}

#pragma makr - 消息

#pragma mark - 系统委托

#pragma mark - 自定义委托

#pragma mark - 响应方法

#pragma mark - 私有方法

- (void)creatView {
    self.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.5];
}

#pragma mark - get/set方法


@end
