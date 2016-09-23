//
//  CodingBanner.m
//  Coding_iOS
//
//  Created by Ease on 15/7/29.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "CodingBanner.h"

@implementation CodingBanner
- (NSString *)displayName{
    return [NSString stringWithFormat:@"%@    ", _name.length > 0? _name: @"..."];
}
@end
