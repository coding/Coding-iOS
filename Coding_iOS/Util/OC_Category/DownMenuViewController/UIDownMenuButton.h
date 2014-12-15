//
//  UIDownMenuButton.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-5.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DownMenuTitle;

@interface UIDownMenuButton : UIButton <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, assign) NSInteger curIndex;

- (UIDownMenuButton *)initWithTitles:(NSArray *)titleList andDefaultIndex:(NSInteger)index andVC:(UIViewController *)viewcontroller;
@property (nonatomic,copy) void(^menuIndexChanged)(id titleObj, NSInteger index);

@end

@interface DownMenuTitle : NSObject
@property (nonatomic, strong) NSString *titleValue, *imageName, *badgeValue;
+ (DownMenuTitle *)title:(NSString *)title image:(NSString *)image badge:(NSString *)badge;
@end