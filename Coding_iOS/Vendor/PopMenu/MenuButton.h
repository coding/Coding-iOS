//
//  MenuButton.h
//  JackFastKit
//
//  Created by 曾 宪华 on 14-10-13.
//  Copyright (c) 2014年 华捷 iOS软件开发工程师 曾宪华. All rights reserved.
//

// ==========================================
//  MenuButton 菜单视图 UIView  处理点击事件等
// ==========================================
#import <UIKit/UIKit.h>

@class MenuItem;

typedef void(^DidSelctedItemCompletedBlock)(MenuItem *menuItem);

@interface MenuButton : UIView

/**
 *  点击操作
 */
@property (nonatomic, copy) DidSelctedItemCompletedBlock didSelctedItemCompleted;

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame menuItem:(MenuItem *)menuItem;

@end
