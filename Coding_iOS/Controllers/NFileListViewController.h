//
//  NFileListViewController.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/5/11.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "ProjectFile.h"
#import "Project.h"

@interface NFileListViewController : BaseViewController
@property (nonatomic, strong) Project *curProject;
@property (strong, nonatomic) ProjectFile *curFolder;
@end
