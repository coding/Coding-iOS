//
//  PrivateMessages.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "PrivateMessages.h"
#include "Login.h"

@implementation PrivateMessages
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"PrivateMessage", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:30];
        _curFriend = nil;
    }
    return self;
}

+ (PrivateMessages *)priMsgsWithUser:(User *)user{
    PrivateMessages *priMsgs = [[PrivateMessages alloc] init];
    priMsgs.curFriend = user;
    return priMsgs;
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
        path = [NSString stringWithFormat:@"api/message/conversations/%@", _curFriend.global_key];
    }else{
        path = @"api/message/conversations";
    }
    return path;
}
- (NSDictionary *)toParams{
    return @{@"page" : _willLoadMore? [NSNumber numberWithInt:_page.intValue +1]: [NSNumber numberWithInt:1],
             @"pageSize" : _pageSize};
}
- (void)configWithObj:(PrivateMessages *)priMsgs{
    self.page = priMsgs.page;
    self.pageSize = priMsgs.pageSize;
    self.totalPage = priMsgs.totalPage;
    if (_willLoadMore) {
        [self.list addObjectsFromArray:priMsgs.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:priMsgs.list];
    }
    _canLoadMore = _page.intValue < _totalPage.intValue;
}

- (void)sendNewMessage:(PrivateMessage *)nextMsg{
    if (!nextMsg) {
        return;
    }
    if (!_nextMessages) {
        _nextMessages = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if (!_list) {
        _list = [[NSMutableArray alloc] initWithCapacity:1];
    }
    NSUInteger index = [_nextMessages indexOfObject:nextMsg];
    if (index == NSNotFound) {
        [_nextMessages insertObject:nextMsg atIndex:0];
        [_list insertObject:nextMsg atIndex:0];
    }else{
        if (index != 0) {
            [_nextMessages exchangeObjectAtIndex:index withObjectAtIndex:0];
        }
        NSUInteger indexInList = [_list indexOfObject:nextMsg];
        if (indexInList && indexInList!= 0) {
            [_list exchangeObjectAtIndex:indexInList withObjectAtIndex:0];
        }
    }
}
- (void)sendSuccessMessage:(PrivateMessage *)sucessMsg andOldMessage:(PrivateMessage *)oldMsg{
    if (_nextMessages) {
        [_nextMessages removeObject:oldMsg];
    }
    NSUInteger index = [_list indexOfObject:oldMsg];
    if (index != NSNotFound) {
        [_list replaceObjectAtIndex:index withObject:sucessMsg];
    }
}
- (void)deleteMessage:(PrivateMessage *)msg{
    [_list removeObject:msg];
}
@end














