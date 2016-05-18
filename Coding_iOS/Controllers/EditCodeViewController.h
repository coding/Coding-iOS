//
//  EditCodeViewController.h
//  Coding_iOS
//
//  Created by Ease on 16/1/11.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Projects.h"
#import "CodeFile.h"

@interface EditCodeViewController : BaseViewController
@property (strong, nonatomic) Project *myProject;
@property (strong, nonatomic) CodeFile *myCodeFile;
@property (copy, nonatomic) void(^savedSucessBlock)();

@end
