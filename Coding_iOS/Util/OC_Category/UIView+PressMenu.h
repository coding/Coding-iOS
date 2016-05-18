//
//  UIView+PressMenu.h
//  Coding_iOS
//
//  Created by Ease on 15/6/9.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PressMenu)
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) UILongPressGestureRecognizer *pressGR;
@property (copy, nonatomic) void(^menuClickedBlock)(NSInteger index, NSString *title);
@property (strong, nonatomic) UIMenuController *menuVC;

- (void)addPressMenuTitles:(NSArray *)menuTitles menuClickedBlock:(void(^)(NSInteger index, NSString *title))block;
- (void)showMenuTitles:(NSArray *)menuTitles menuClickedBlock:(void(^)(NSInteger index, NSString *title))block;

- (BOOL)isMenuVCVisible;
- (void)removePressMenu;
@end
