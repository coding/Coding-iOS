//
//  TaskDescriptionViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/1/8.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface TaskDescriptionViewController : BaseViewController
@property (strong, nonatomic) NSString *markdown;
@property (copy, nonatomic) void(^savedNewMDBlock)(NSString *mdStr, NSString *mdHtmlStr);

@end
