//
//  EACodeReleases.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/22.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EACodeReleases.h"

@implementation EACodeReleases
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.propertyArrayMap = @{@"list": @"EACodeRelease"};
    }
    return self;
}

//https://coding.net/api/user/ease/project/CodingTest/git/releases?page=1&pageSize=10
- (NSString *)toPath{
    return [NSString stringWithFormat:@"api/user/%@/project/%@/git/releases", _curPro.owner_user_name, _curPro.name];
}
- (NSDictionary *)toParams{
    return [super toParams];
}

@end
