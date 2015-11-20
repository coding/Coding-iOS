//
//  CodingTips.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "CodingTips.h"

@implementation CodingTips
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"CodingTip", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _type = 0;
    }
    return self;
}

- (void)setOnlyUnread:(BOOL)onlyUnread{
    if (_onlyUnread != onlyUnread) {
        _onlyUnread = onlyUnread;
        //初始化数据
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
        _canLoadMore = YES;
        if (_list) {
            [_list removeAllObjects];
        }
    }
}

+(CodingTips *)codingTipsWithType:(NSInteger)type{
    CodingTips *tips = [[CodingTips alloc] init];
    tips.type = type;
    return tips;
}

- (void)configWithObj:(CodingTips *)tips{
    self.page = tips.page;
    self.pageSize = tips.pageSize;
    self.totalPage = tips.totalPage;
    if (_willLoadMore) {
        [self.list addObjectsFromArray:tips.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:tips.list];
    }
    _canLoadMore = _page.intValue < _totalPage.intValue;
}

- (NSString *)toTipsPath{
    NSString *path;
    if (_onlyUnread) {
        path = @"api/notification/unread-list";
    }else{
        path = @"api/notification";
    }
    return path;
}
- (NSDictionary *)toTipsParams{
    NSDictionary *params;
    if (_type == 0) {
        params = @{@"type" : @(0),
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 1){
        params = @{@"type" : @[@(1), @(2)],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 2){
        params = @{@"type" : @[@(4), @(6)],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }
    return params;
}

- (NSDictionary *)toMarkReadParams{
    NSDictionary *params;
    if (_type == 0) {
        params = @{@"type" : @(0),
                   @"all" : @(1)};
    }else if (_type == 1){
        params = @{@"type" : @[@(1), @(2)],
                   @"all" : @(1)};
    }else if (_type == 2){
        params = @{@"type" : @(4),
                   @"all" : @(1)};
    }
    return params;
}
@end
