//
//  ZXScanCodeViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/7/2.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "OTPAuthURL.h"

@interface ZXScanCodeViewController : BaseViewController

@property (copy, nonatomic) void(^sucessScanBlock)(OTPAuthURL *authURL);

@end
