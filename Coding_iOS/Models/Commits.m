//
//  Commits.m
//  Coding_iOS
//
//  Created by Ease on 15/6/5.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "Commits.h"

@implementation Commits
- (instancetype)init
{
    self = [super init];
    if (self) {
        _canLoadMore = NO;
        _isLoading = NO;
        _willLoadMore = NO;
        _pageSize = [NSNumber numberWithInteger:20];
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"Commit", @"list", nil];
        _listGroups = [[NSMutableArray alloc] init];
        _list = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (Commits *)commitsWithRef:(NSString *)ref Path:(NSString *)path{
    Commits *commits = [Commits new];
    commits.ref = ref;
    commits.path = path;
    return commits;
}

- (NSDictionary *)toParams{
    return  @{@"page" : [NSNumber numberWithInteger:_willLoadMore? self.page.integerValue+1 : 1],
              @"pageSize" : self.pageSize};
}

- (void)configWithCommits:(Commits *)responseCommits{
    self.page = responseCommits.page;
    self.totalRow = responseCommits.totalRow;
    self.totalPage = responseCommits.totalPage;
    if (responseCommits.list.count > 0) {
        self.canLoadMore = YES;
        if (_willLoadMore) {
            [self.list addObjectsFromArray:responseCommits.list];
        }else{
            self.list = [NSMutableArray arrayWithArray:responseCommits.list];
        }
        [self refreshListGroupWithCommits:responseCommits isAdd:self.willLoadMore];
    }else{
        self.canLoadMore = NO;
    }
}

- (void)refreshListGroupWithCommits:(Commits *)responseCommits isAdd:(BOOL)isAdd{
    if (!isAdd) {
        [_listGroups removeAllObjects];
    }
    for (NSUInteger i = 0; i< [responseCommits.list count]; i++) {
        Commit *curCommit = [responseCommits.list objectAtIndex:i];
        NSUInteger location = [_list indexOfObject:curCommit];
        if (location != NSNotFound) {
            ListGroupItem *item = _listGroups.lastObject;
            if (item && [item.date isSameDay:curCommit.commitTime]) {
                [item addOneItem];
            }else{
                item = [ListGroupItem itemWithDate:curCommit.commitTime andLocation:location];
                [item addOneItem];
                [_listGroups addObject:item];
            }
        }
    }
}
@end
