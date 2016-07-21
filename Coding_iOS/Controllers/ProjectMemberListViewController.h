//
//  ProjectMemberListViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Projects.h"
#import "ProjectMember.h"
typedef NS_ENUM(NSInteger, ProMemType) {
    ProMemTypeProject = 0,
    ProMemTypeTaskOwner,
    ProMemTypeAT,
    ProMemTypeTaskWatchers,
    ProMemTypeTopicWatchers
};
typedef void(^ProjectMemberBlock)(ProjectMember *member);
typedef void(^ProjectMemberListBlock)(NSArray *memberArray);
typedef void(^ProjectMemberCellBtnBlock)(ProjectMember *member);

@interface ProjectMemberListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,UISearchDisplayDelegate>
@property (strong, nonatomic) NSMutableArray *myMemberArray;
@property (strong, nonatomic) Task *curTask;
@property (strong, nonatomic) ProjectTopic *curTopic;
- (void)setFrame:(CGRect)frame project:(Project *)project type:(ProMemType)type refreshBlock:(ProjectMemberListBlock)refreshBlock selectBlock:(ProjectMemberBlock)selectBlock cellBtnBlock:(ProjectMemberCellBtnBlock)cellBtnBlock;
- (void)willHiden;
- (void)refreshMembersData;

+ (void)showATSomeoneWithBlock:(void(^)(User *curUser))block withProject:(Project *)project;
@property (copy, nonatomic) void(^selectUserBlock)(User *selectedUser);
@end
