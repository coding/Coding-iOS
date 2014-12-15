//
//  UIViewController+DownMenu.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UIViewController+DownMenu.h"

@implementation UIViewController (DownMenu)
- (UIDownMenuButton *)customDownMenuWithTitles:(NSArray *)titleList andDefaultIndex:(NSInteger)index andBlock:(void (^)(id titleObj, NSInteger index))block{
    UIDownMenuButton *navBtn = [[UIDownMenuButton alloc] initWithTitles:titleList andDefaultIndex:index andVC:self];
    navBtn.menuIndexChanged = block;
    self.navigationItem.titleView = navBtn;
    return navBtn;
}
- (UIDownMenuButton *)downMenuBtn{
    if (self.navigationItem.titleView || [self.navigationItem.titleView isKindOfClass:[UIDownMenuButton class]]) {
        UIDownMenuButton *navBtn = (UIDownMenuButton *)self.navigationItem.titleView;
        return navBtn;
    }else{
        return nil;
    }
}
@end
