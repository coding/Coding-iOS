//
//  PasswordViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, PasswordType) {
    PasswordReset = 0,
    PasswordActivate,
};

@interface PasswordViewController : BaseViewController
@property (nonatomic, assign) PasswordType type;
@property (strong, nonatomic) NSString *email, *key, *password, *confirm_password;
@property (nonatomic, copy) void(^successBlock)(PasswordViewController *vc, id data);
+ (id)passwordVCWithType:(PasswordType)type email:(NSString *)email andKey:(NSString *)key;
@end
