//
//  WebViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/1/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface WebViewController : BaseViewController

@property (strong, nonatomic) NSURL *curUrl;

+ (instancetype)webVCWithUrl:(NSURL *)curUrl;

@end
