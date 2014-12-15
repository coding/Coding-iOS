//
//  UIViewController+DownMenu.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDownMenuButton.h"
@class DownMenuTitle;

@interface UIViewController (DownMenu)
- (UIDownMenuButton *)customDownMenuWithTitles:(NSArray *)titleList andDefaultIndex:(NSInteger)index andBlock:(void (^)(id titleObj, NSInteger index))block;
- (UIDownMenuButton *)downMenuBtn;
@end

