//
//  EALocalCodeViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Project.h"

@interface EALocalCodeViewController : BaseViewController
@property (strong, nonatomic) Project *curPro;
@property (strong, nonatomic) GTRepository *curRepo;
@property (strong, nonatomic) NSURL *curURL;
@end
