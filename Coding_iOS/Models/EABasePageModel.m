//
//  EABasePageModel.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EABasePageModel.h"

@implementation EABasePageModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = @{
//                              @"list": @"CodeBranchOrTag",
                              };
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = @1;
        _pageSize = @20;
    }
    return self;
}

- (NSMutableDictionary *)toParams{
    return @{@"page" : (_willLoadMore? @(_page.intValue +1): @1),
             @"pageSize" : _pageSize}.mutableCopy;

}

- (void)configWithObj:(EABasePageModel *)resultA{
    self.page = resultA.page;
    self.totalPage = resultA.totalPage;
    self.totalRow = resultA.totalRow;
    if (_willLoadMore) {
        [self.list addObjectsFromArray:resultA.list];
    }else{
        self.list = [NSMutableArray arrayWithArray:resultA.list];
    }
    self.canLoadMore = self.page.intValue < self.totalPage.intValue;
}

@end
