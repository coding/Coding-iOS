//
//  EaseUserInfoCell.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/28.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_EaseUserInfoCell @"EaseUserInfoCell"

#import <UIKit/UIKit.h>


@interface EaseUserInfoCell : UITableViewCell
@property (nonatomic, strong) User *user;

@property (nonatomic, copy) void (^userIconClicked)();
@property (nonatomic, copy) void (^fansCountBtnClicked)();
@property (nonatomic, copy) void (^followsCountBtnClicked)();
@property (nonatomic, copy) void (^followBtnClicked)();
@property (nonatomic, copy) void (^editButtonClicked)();
@property (nonatomic, copy) void (^messageBtnClicked)();
@property (nonatomic, copy) void (^detailInfoBtnClicked)();


@end
