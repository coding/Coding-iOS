//
//  CannotLoginViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Coding_NetAPIManager.h"

typedef NS_ENUM(NSInteger, CannotLoginMethodType) {
    CannotLoginMethodEamil = 0,
    CannotLoginMethodPhone
};

@interface CannotLoginViewController : BaseViewController
+ (instancetype)vcWithMethodType:(CannotLoginMethodType)methodType stepIndex:(NSUInteger)stepIndex userStr:(NSString *)userStr;

@end
