//
//  CannotLoginViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/3/26.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, CannotLoginType) {
    CannotLoginTypeResetPassword = 0,
    CannotLoginTypeActivate,
};


@interface CannotLoginViewController : BaseViewController
@property (nonatomic, assign) CannotLoginType type;

@property (strong, nonatomic) NSString *email, *j_captcha;

@end
