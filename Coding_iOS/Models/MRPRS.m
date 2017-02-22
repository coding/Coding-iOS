//
//  MRPRS.m
//  Coding_iOS
//
//  Created by Ease on 15/5/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "MRPRS.h"

@implementation MRPRS
- (instancetype)init
{
    self = [super init];
    if (self) {
        _propertyArrayMap = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"MRPR", @"list", nil];
        _canLoadMore = YES;
        _isLoading = _willLoadMore = NO;
        _page = [NSNumber numberWithInteger:1];
        _pageSize = [NSNumber numberWithInteger:20];
    }
    return self;
}

-(instancetype)initWithType:(MRPRSType)type userGK:(NSString *)user_gk projectName:(NSString *)project_name{
    self = [self init];
    if (self) {
        _type = type;
        _user_gk = user_gk;
        _project_name = project_name;
    }
    return self;
}

- (NSDictionary *)toParams{
    NSMutableDictionary *params = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
                                    @"pageSize" : _pageSize}.mutableCopy;
    params[@"status"] = (_type == MRPRSTypeMRCanMerge? @"canmerge":
                         _type == MRPRSTypeMRCannotMerge? @"cannotmerge":
                         _type == MRPRSTypeMRRefused? @"refused":
                         _type == MRPRSTypeMRAccepted? @"accepted":
                         nil);
    return params;
}
- (NSString *)toPath{
    NSString *typeStr;
    if (_type < MRPRSTypePROpen) {
        typeStr = @"merges/filter";
    }else{
        typeStr = (_type == MRPRSTypePROpen? @"pulls/open":
                   _type == MRPRSTypePRClosed? @"pulls/closed":
                   _type == MRPRSTypePRAll? @"pulls/all":
                   @"");
    }
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/%@", _user_gk, _project_name, typeStr];
}
- (void)configWithMRPRS:(MRPRS *)resultA{
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
