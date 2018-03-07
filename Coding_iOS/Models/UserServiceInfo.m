//
//  ServiceInfo.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/8.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "UserServiceInfo.h"

@implementation UserServiceInfo

- (void)setPublic_project_quota:(NSString *)public_project_quota{
    _public_project_quota = [public_project_quota isKindOfClass:[NSNumber class]]? ((NSNumber *)public_project_quota).stringValue: public_project_quota;
}

- (void)setPrivate_project_quota:(NSString *)private_project_quota{
    _private_project_quota = [private_project_quota isKindOfClass:[NSNumber class]]? ((NSNumber *)private_project_quota).stringValue: private_project_quota;
}

@end
