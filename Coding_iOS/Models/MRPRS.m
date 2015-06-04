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

+(instancetype)MRPRSWithType:(MRPRSType)type userGK:(NSString *)user_gk projectName:(NSString *)project_name{
    MRPRS *obj = [[MRPRS alloc] init];
    obj.type = type;
    obj.user_gk = user_gk;
    obj.project_name = project_name;
    return obj;
}
- (NSDictionary *)toParams{
    return @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
             @"pageSize" : _pageSize};
}
- (NSString *)toPath{
    NSString *typeStr;
    switch (_type) {
        case MRPRSTypeMRAll:
            typeStr = @"merges/all";
            break;
        case MRPRSTypeMROpen:
            typeStr = @"merges/open";
            break;
        case MRPRSTypeMRClose:
            typeStr = @"merges/closed";
            break;
        case MRPRSTypePRAll:
            typeStr = @"pulls/all";
            break;
        case MRPRSTypePROpen:
            typeStr = @"pulls/open";
            break;
        case MRPRSTypePRClose:
            typeStr = @"pulls/closed";
            break;
        default:
            typeStr = @"";
            break;
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
