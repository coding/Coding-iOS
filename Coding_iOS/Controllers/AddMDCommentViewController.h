//
//  AddMDCommentViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"

@interface AddMDCommentViewController : BaseViewController
@property (strong, nonatomic) void (^completeBlock)(id data);
@property (strong, nonatomic) NSString *requestPath;
@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSString *contentStr;
@property (strong, nonatomic) Project *curProject;
@property (assign, nonatomic) BOOL isLineNote;//这个字段单纯是为友盟统计的，没啥特别的作用

@end
