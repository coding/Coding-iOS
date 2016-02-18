//
//  RegisterViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-1.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Register.h"

typedef NS_ENUM(NSInteger, RegisterMethodType) {
    RegisterMethodEamil = 0,
    RegisterMethodPhone,
};

@interface RegisterViewController : BaseViewController
+ (instancetype)vcWithMethodType:(RegisterMethodType)methodType registerObj:(Register *)obj;
@end
