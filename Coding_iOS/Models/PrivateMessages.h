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
@property (assign, nonatomic) BOOL canLoadMore, willLoadMore, isLoading, isPolling;
@property (readwrite, nonatomic, strong) NSDictionary *propertyArrayMap;
@property (readwrite, nonatomic, strong) NSMutableArray *list, *nextMessages, *dataList;
@property (readwrite, nonatomic, strong) User *curFriend;
+ (PrivateMessages *)priMsgsWithUser:(User *)user;
+ (id)analyzeResponseData:(NSDictionary *)responseData;

- (NSString *)localPrivateMessagesPath;
- (NSString *)toPath;
- (NSDictionary *)toParams;

- (NSString *)toPollPath;
- (NSDictionary *)toPollParams;

- (void)configWithObj:(id)anObj;
- (void)configWithPollArray:(NSArray *)pollList;
- (void)sendNewMessage:(PrivateMessage *)nextMsg;
- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg;
- (void)deleteMessage:(PrivateMessage *)msg;

- (void)freshLastId:(NSNumber *)last_id;

@end
