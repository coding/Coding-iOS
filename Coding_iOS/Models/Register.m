//
//  Register.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Register.h"

@implementation Register
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.email = @"";
        self.global_key = @"";
    }
    return self;
}

- (NSDictionary *)toParams{
    return @{@"email" : self.email,
             @"global_key" : self.global_key,
             @"j_captcha" : _j_captcha? _j_captcha: @"",
             @"channel" : [Register channel]};
}

+ (NSString *)channel{
    return @"coding-ios";
}
@end
