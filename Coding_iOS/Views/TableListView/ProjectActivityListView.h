//
//  ProjectActivityListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "UITTTAttributedLabel.h"

typedef void(^ProjectActivityBlock)(ProjectActivity *proActivity);

@interface ProjectActivityListView : UIView<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (copy, nonatomic) void (^htmlItemClickedBlock)(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent);
@property (copy, nonatomic) void (^userIconClickedBlock)(User *);

- (id)initWithFrame:(CGRect)frame proAtcs:(ProjectActivities *)proAtcs block:(ProjectActivityBlock)block;
- (void)setProAtcs:(ProjectActivities *)proAtcs;
@end
