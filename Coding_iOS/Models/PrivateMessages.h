//
//  PrivateMessages.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrivateMessage.h"

@interface PrivateMessages : NSObject
@property (readwrite, nonatomic, strong) NSNumber *page, *pageSize, *totalPage, *totalRow;
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *nextMessages;
@property (readwrite, nonatomic, strong) User *curFriend;
//@property (readwrite, nonatomic, strong) NSString *nextContent;
+ (PrivateMessages *)priMsgsWithUser:(User *)user;

- (NSString *)localPrivateMessagesPath;
- (NSString *)toPath;
- (NSDictionary *)toParams;
- (void)configWithObj:(PrivateMessages *)priMsgs;

- (void)sendNewMessage:(PrivateMessage *)nextMsg;
- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg;

- (void)deleteMessage:(PrivateMessage *)msg;
@end
