//
//  NSObject+MRPRPreInfo.m
//  Coding_iOS
//
//  Created by hardac on 16/4/2.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "MRPRPreInfo.h"

@implementation MRPRPreInfo
- (instancetype)init
{
    self = [super init];

    return self;
}
- (MRPR *)mrpr{
    if (_pull_request) {
        return _pull_request;
    }else{
        return _merge_request;
    }
}
@end
