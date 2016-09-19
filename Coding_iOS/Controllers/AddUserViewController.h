//
//  AddUserViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-15.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"
#import "ProjectMember.h"

typedef NS_ENUM(NSInteger, AddUserType) {
    AddUserTypeProjectRoot = 0,
    AddUserTypeProjectFollows,//我的关注
    AddUserTypeProjectFans,//我的粉丝
    AddUserTypeFollow//添加好友
};
@interface AddUserViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (assign, nonatomic) AddUserType type;
@property (strong, nonatomic) Project *curProject;
@property (copy, nonatomic) void(^popSelfBlock)();
@property (strong, nonatomic) NSMutableArray *queryingArray, *addedArray;
@property (strong, nonatomic) NSArray *searchedArray;
- (void)configAddedArrayWithMembers:(NSArray *)memberArray;
@end
