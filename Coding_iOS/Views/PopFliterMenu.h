//
//  PopFliterMenu.h
//  Coding_iOS
//
//  Created by jwill on 15/11/10.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopFliterMenu : UIView
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;
//将菜单显示到某个视图上
- (void)showMenuAtView:(UIView *)containerView;
//取消视图
- (void)dismissMenu;
@end
