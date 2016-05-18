//
//  PointRecords.m
//  Coding_iOS
//
//  Created by Ease on 15/8/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "PointRecords.h"

@implementation PointRecords
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"PointRecord", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = @(1);
        _pageSize = @(20);
    }
    return self;
}
- (NSString *)toPath{
    return @"api/point/records";
}
- (NSDictionary *)toParams{
    return @{@"page" : _willLoadMore? @(_page.integerValue +1) : @(1),
             @"pageSize" : _pageSize};
}
- (void)configWithObj:(PointRecords *)records{
    self.page = records.page;
    self.pageSize = records.pageSize;
    self.totalPage = records.totalPage;
    if (_willLoadMore) {
        [self.list addObjectsFromArray:records.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:records.list];
    }
    _canLoadMore = _page.intValue < _totalPage.intValue;
}
@end
