//
//  PrivateMessages.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "PrivateMessages.h"
#include "Login.h"

@interface PrivateMessages ()
@property (strong, nonatomic) NSNumber *p_lastId;
@end

@implementation PrivateMessages
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"PrivateMessage", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = _isPolling = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _curFriend = nil;
    }
    return self;
}

- (NSMutableArray *)list{
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray *)nextMessages{
    if (!_nextMessages) {
        _nextMessages = [[NSMutableArray alloc] init];
    }
    return _nextMessages;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

- (NSMutableArray *)reset_dataList{
    [self.dataList removeAllObjects];
    if (_list.count > 0) {
        self.dataList = [_list mutableCopy];
    }
    if (_nextMessages.count > 0) {
        [self.dataList insertObjects:_nextMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _nextMessages.count)]];
    }
    return _dataList;
}

+ (PrivateMessages *)priMsgsWithUser:(User *)user{
    PrivateMessages *priMsgs = [[PrivateMessages alloc] init];
    priMsgs.curFriend = user;
    return priMsgs;
}

+ (id)analyzeResponseData:(NSDictionary *)responseData{
    id data = [responseData valueForKeyPath:@"data"];
    if (!data) {//旧数据直接保存的data属性
        data = responseData;
    }
    id resultA = nil;
    if ([data isKindOfClass:[NSArray class]]) {
        resultA = [NSObject arrayFromJSON:data ofObjects:@"PrivateMessage"];
    }else if (data){
        resultA = [NSObject objectOfClass:@"PrivateMessages" fromJSON:data];
    }
    return resultA;
}

- (NSString *)localPrivateMessagesPath{
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"conversations_%@", _curFriend.global_key];
    }else{
        path = @"conversations";
    }
    return path;
}
- (NSString *)toPath{
    NSString *path;
    if (_curFriend) {
        path = [NSString stringWithFormat:@"api/message/conversations/%@/prev", _curFriend.global_key];
    }else{
        path = @"api/message/conversations";
    }
    return path;
}
- (NSDictionary *)toParams{
    NSDictionary *params = nil;
    if (_curFriend) {
        NSNumber *prevId = kDefaultLastId;
        if (_willLoadMore && _list.count > 0) {
            PrivateMessage *prev_Msg = [_list lastObject];
            prevId = prev_Msg.id;
        }
        params = @{@"id" : prevId,
                   @"pageSize" : _pageSize};
    }else{
        params = @{@"page" : _willLoadMore? [NSNumber numberWithInt:_page.intValue +1]: [NSNumber numberWithInt:1],
                   @"pageSize" : _pageSize};
    }
    return params;
}

- (NSString *)toPollPath{
    return [NSString stringWithFormat:@"api/message/conversations/%@/last", _curFriend.global_key];
}
- (NSDictionary *)toPollParams{
    return @{@"id" : self.p_lastId};
}

- (void)freshLastId:(NSNumber *)last_id{
    self.p_lastId = last_id;
}


- (NSNumber *)p_lastId{
    if (!_p_lastId) {
        _p_lastId = @0;
        [_list enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
            if (obj.id.integerValue > 0) {
                _p_lastId = obj.id;
                *stop = YES;
            }
        }];
    }
    return _p_lastId;
}

- (BOOL)p_addMsg:(PrivateMessage *)aMsg{
    NSInteger curId = aMsg.id.integerValue;
    
    __block NSInteger add_index;
    __block BOOL needToAdd = NO;
    
    if (self.list.count > 0) {
        [self.list enumerateObjectsUsingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
            if (curId == obj.id.integerValue) {
                needToAdd = NO;
                *stop = YES;
            }else if (curId > obj.id.integerValue){
                needToAdd = YES;
                add_index = idx;
                *stop = YES;
            }
        }];
        if (needToAdd) {
            [self.list insertObject:aMsg atIndex:add_index];
        }
    }else{
        needToAdd = YES;
        [self.list addObject:aMsg];
    }
    return needToAdd;
}

- (void)configWithObj:(id)anObj{
    if ([anObj isKindOfClass:[PrivateMessages class]]) {
        PrivateMessages *priMsgs = (PrivateMessages *)anObj;
        self.page = priMsgs.page;
        self.pageSize = priMsgs.pageSize;
        self.totalPage = priMsgs.totalPage;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:priMsgs.list];
        self.canLoadMore = _page.intValue < _totalPage.intValue;
    }else if ([anObj isKindOfClass:[NSArray class]]){
        NSArray *list = (NSArray *)anObj;
        if (!_willLoadMore) {
            [self.list removeAllObjects];
        }
        [self.list addObjectsFromArray:list];
        self.canLoadMore = list.count > 0;
    }
    [self reset_dataList];
}

- (void)configWithPollArray:(NSArray *)pollList{
    if (pollList.count <= 0) {
        return;
    }
    
    __block BOOL hasNewData = NO;
    __weak typeof(self) weakSelf = self;
    [pollList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(PrivateMessage *obj, NSUInteger idx, BOOL *stop) {
        if ([weakSelf p_addMsg:obj]) {
            hasNewData = YES;
        }
    }];
    if (hasNewData) {
        [self reset_dataList];
    }
}

- (void)sendNewMessage:(PrivateMessage *)nextMsg{
    [self p_addObj:nextMsg toArray:self.nextMessages];
    [self reset_dataList];
}
- (void)p_addObj:(id)anObj toArray:(NSMutableArray *)list{
    if (!anObj || !list) {
        return;
    }
    NSUInteger index = [list indexOfObject:anObj];
    if (index == NSNotFound) {
        [list insertObject:anObj atIndex:0];
    }else if (index != 0){
        [list exchangeObjectAtIndex:index withObjectAtIndex:0];
    }
}

- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg{
    if (!sucessMsg || !oldMsg) {
        DebugLog(@"sucessMsg and oldMsg should not be nil");
        return;
    }
    [self.nextMessages removeObject:oldMsg];
    [self p_addMsg:sucessMsg];
    [self reset_dataList];
}
- (void)deleteMessage:(PrivateMessage *)msg{
    [self.list removeObject:msg];
    [self.nextMessages removeObject:msg];
    [self reset_dataList];
}
@end



