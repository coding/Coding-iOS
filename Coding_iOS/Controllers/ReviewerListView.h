//
//  NSObject+ReviewerListView.h
//  Coding_iOS
//
//  Created by hardac on 16/3/25.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"

typedef void(^ReviewerListViewBlock)(Project *project);

@interface ReviewerListView : UIView<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,assign)BOOL useNewStyle;
@property(copy, nonatomic) void(^clickButtonBlock)(EaseBlankPageType curType);

- (id)initWithFrame:(CGRect)frame projects:(Projects *)projects block:(ReviewerListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setProjects:(Projects *)projects;

@end
