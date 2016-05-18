//
//  LocalFileViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface LocalFileViewController : BaseViewController
@property (strong, nonatomic) NSString *projectName;
@property (strong, nonatomic) NSURL *fileUrl;
@property (copy, nonatomic) void (^fileHasBeenDeletedBlock)(NSURL *fileUrl);//暂时不在这个页面做删除
@end
