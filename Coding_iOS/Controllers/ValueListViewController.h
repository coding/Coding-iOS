//
//  ValueListViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-26.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Task.h"

typedef NS_ENUM(NSInteger, ValueListType) {
    ValueListTypeTaskStatus = 0,
    ValueListTypeTaskPriority,
    ValueListTypeProjectMemberType
};
typedef void(^IndexSelectedBlock)(NSInteger index);

@interface ValueListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

- (void)setTitle:(NSString *)title valueList:(NSArray *)list defaultSelectIndex:(NSInteger)index type:(ValueListType)type selectBlock:(IndexSelectedBlock)selectBlock;


@end




