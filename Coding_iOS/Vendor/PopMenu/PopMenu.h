//
//  MenuView.h
//  JackFastKit
//
//  Created by 曾 宪华 on 14-10-13.
//  Copyright (c) 2014年 华捷 iOS软件开发工程师 曾宪华. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"

typedef NS_ENUM(NSInteger, PopMenuAnimationType) {
    /** 从下部入 下部出*/
    kPopMenuAnimationTypeSina = 0,
    /** 从右侧入 左侧出*/
    kPopMenuAnimationTypeNetEase = 1,
};

/**
 *  选中菜单按钮 操作
 *
 *  @param selectedItem 菜单按钮
 */
typedef void(^DidSelectedItemBlock)(MenuItem *selectedItem);

// ==========================================
//  PopMenu 菜单栏
// ==========================================
@interface PopMenu : UIView

/**
 *  菜单动画格式
 */
@property (nonatomic, assign) PopMenuAnimationType menuAnimationType;

/**
 *  是否显示
 */
@property (nonatomic, assign, readonly) BOOL isShowed;

/**
 *  菜单中菜单元素
 */
@property (nonatomic, strong, readonly) NSArray *items;

// 每行有多少列 Default is 3
@property (nonatomic, assign) NSInteger perRowItemCount;

/**
 *  点击菜单元素,Block会把点击的菜单元素当成参数返回给用户，用户可以拿到菜单元素对点击，做相应的操作
 */
@property (nonatomic, copy) DidSelectedItemBlock didSelectedItemCompletion;

#pragma mark - init 初始化

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;

#pragma mark - show
#pragma mark 将菜单显示到某个视图上

- (void)showMenuAtView:(UIView *)containerView;

#pragma mark 控制菜单从哪个点的进 和 出

/**
 *  将菜单  开始 现实到哪个point 上  在哪个 point 结束
 *
 *  此效果用于 在 PopMenu AnimationType 为 kPopMenuAnimationTypeNetEase 有效，
 *  @param containerView 显示在哪个视图容器上
 *  @param startPoint    菜单从哪个 点 进入 容器 展示效果
 *  @param endPoint      菜单从哪个 点 出 容器
 */
- (void)showMenuAtView:(UIView *)containerView startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

#pragma mark - dismiss
/**
 *  容器dismiss
 */
- (void)dismissMenu;

@end
