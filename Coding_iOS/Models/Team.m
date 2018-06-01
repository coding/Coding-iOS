//
//  Team.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kEAMaxTrialDays 15

#import "Team.h"

@implementation Team
+ (instancetype)teamWithGK:(NSString *)global_key{
    Team *team = [Team new];
    team.global_key = global_key;
    return team;
}

- (NSString *)toUpdateInfoPath{
    return [NSString stringWithFormat:@"api/team/%@/update", _global_key];
}
- (NSDictionary *)toUpdateInfoParams{
    return @{@"global_key": _global_key,
             @"name": _name,
             @"introduction": _introduction ?: @"",
             };
}

@end

@implementation TeamInfo
- (BOOL)isToped_up{//是否充过值
    return _payed? _payed.boolValue: _balance.integerValue > 0;
}

- (NSInteger)stopped_days{//停用天数
    if (_suspended_at) {
        return MAX(0, [_suspended_at daysAgo]);
    }else{
        return MAX(0, [_estimate_date daysAgo] - ([self isToped_up]? 5: 0));
    }
}

- (NSInteger)beyond_days{//超期天数
    return MAX(0, [_estimate_date daysAgo]);
}

- (NSInteger)trial_left_days{//试用期剩余天数
    return MAX(0, kEAMaxTrialDays - MAX(0, [_created_at daysAgo]));
}
@end
