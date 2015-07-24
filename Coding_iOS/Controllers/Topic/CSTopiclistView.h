//
//  CSTopiclistView.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/24.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
typedef void(^TopicListViewBlock)(id topic);

@interface CSTopiclistView : UIView<UITableViewDataSource, UITableViewDelegate>

- (id)initWithFrame:(CGRect)frame topics:(id )topic block:(TopicListViewBlock)block tabBarHeight:(CGFloat)tabBarHeight;
- (void)setTopics:(id )topics;
- (void)refreshUI;

@end


@interface CSTopiclistCell : SWTableViewCell

@end