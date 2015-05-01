//
//  UsersViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Users.h"
#import "PrivateMessage.h"

@interface UsersViewController : BaseViewController
@property (strong, nonatomic) Users *curUsers;
@property (strong, nonatomic) PrivateMessage *curMessage;
@property (copy, nonatomic) void(^selectUserBlock)(User *selectedUser);
@property (copy, nonatomic) void(^transpondMessageBlock)(PrivateMessage *curMessage);
+ (void)showATSomeoneWithBlock:(void(^)(User *curUser))block;
+ (void)showTranspondMessage:(PrivateMessage *)curMessage withBlock:(void(^)(PrivateMessage *curMessage))block;
@end
