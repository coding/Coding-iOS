//
//  WebViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/1/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "SVWebViewController.h"

@interface WebViewController : SVWebViewController

@property (strong, nonatomic) NSString *curUrlStr;

+ (instancetype)webVCWithUrlStr:(NSString *)curUrlStr;

@end
