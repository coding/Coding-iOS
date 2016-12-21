//
//  TaskSelectionView.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/12/4.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskSelectionView : UIView

@property (assign) BOOL showStatus;
@property (nonatomic , copy) void (^clickBlock)(NSInteger selectNum);
@property (nonatomic , copy) void (^closeBlock)();
@property (nonatomic, strong) NSArray *items;
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items;
//将菜单显示到某个视图上
- (void)showMenuAtView:(UIView *)containerView;
//取消视图
- (void)dismissMenu;
- (void)refreshMenuDate;


@end
