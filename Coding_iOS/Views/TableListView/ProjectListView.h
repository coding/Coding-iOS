//
//  ProjectListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"

typedef void(^ProjectListViewBlock)(Project *project);

@interface ProjectListView : UIView<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,assign)BOOL useNewStyle;
@property(copy, nonatomic) void(^clickButtonBlock)(EaseBlankPageType curType);

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ProjectListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setSearchBlock:(void(^)())searchBlock andScanBlock:(void(^)())scanBlock;
- (void)setProjects:(Projects *)projects;
- (void)refreshUI;
- (void)refreshToQueryData;
- (void)tabBarItemClicked;

@end
