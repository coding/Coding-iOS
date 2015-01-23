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
    return [NSString stringWithFormat:@"api/notification"];
}
- (NSDictionary *)toTipsParams{
    NSDictionary *params;
    if (_type == 0) {
        params = @{@"type" : [NSNumber numberWithInteger:0],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 1){
        params = @{@"type" : [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], nil],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }else if (_type == 2){
        params = @{@"type" : [NSNumber numberWithInteger:4],
                   @"page" : _willLoadMore? [NSNumber numberWithInteger:_page.integerValue +1]: [NSNumber numberWithInteger:1],
                   @"pageSize" : _pageSize};
    }
    return params;
}

- (NSDictionary *)toMarkReadParams{
    if (!self.list || self.list.count <= 0) {
        return nil;
    }
    
    NSMutableArray *unReadArray = [[NSMutableArray alloc] init];
    for (CodingTip *curTip in self.list) {
        if (!curTip.status.boolValue) {//未读
            [unReadArray addObject:curTip.id];
        }
    }
    
    if (unReadArray.count > 0) {
        return @{@"id" : unReadArray};
    }
    return nil;
    
//    NSDictionary *params;
//    if (_type == 0) {
//        params = @{@"type" : [NSNumber numberWithInteger:0],
//                   @"all" : [NSNumber numberWithInteger:1]};
//    }else if (_type == 1){
//        params = @{@"type" : [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2], nil],
//                   @"all" : [NSNumber numberWithInteger:1]};
//    }else if (_type == 2){
//        params = @{@"type" : [NSNumber numberWithInteger:4],
//                   @"all" : [NSNumber numberWithInteger:1]};
//    }
//    return params;
}
@end
