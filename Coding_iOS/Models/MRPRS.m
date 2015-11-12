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

-(instancetype)initWithType:(MRPRSType)type statusIsOpen:(BOOL)statusIsOpen userGK:(NSString *)user_gk projectName:(NSString *)project_name{
    self = [self init];
    if (self) {
        _type = type;
        _statusIsOpen = statusIsOpen;
        _user_gk = user_gk;
        _project_name = project_name;
    }
    return self;
}

- (NSDictionary *)toParams{
    NSMutableDictionary *params = @{@"page" : (_willLoadMore? [NSNumber numberWithInteger:_page.intValue +1] : [NSNumber numberWithInteger:1]),
                                    @"pageSize" : _pageSize}.mutableCopy;
    if (_type != MRPRSTypePR || _type != MRPRSTypeMRAll) {
        params[@"status"] = _statusIsOpen? @"open": @"closed";
    }
    return params;
}
- (NSString *)toPath{
    NSString *typeStr;
    switch (_type) {
        case MRPRSTypeMRAll:
            if (_statusIsOpen) {
                typeStr = @"merges/open";
            }else{
                typeStr = @"merges/closed";
            }
            break;
        case MRPRSTypeMRMine:
            typeStr = @"merges/list/mine";
            break;
        case MRPRSTypeMRReview:
            typeStr = @"merges/list/review";
            break;
        case MRPRSTypeMROther:
            typeStr = @"merges/list/other";
            break;
        case MRPRSTypePR:
            if (_statusIsOpen) {
                typeStr = @"pulls/open";
            }else{
                typeStr = @"pulls/closed";
            }
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
