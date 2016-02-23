//
//  OTPListViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface OTPListViewController : BaseViewController
+ (NSString *)otpCodeWithGK:(NSString *)global_key;
+ (BOOL)handleScanResult:(NSString *)resultStr ofVC:(UIViewController *)vc;
@end
