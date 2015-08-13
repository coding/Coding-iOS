//
//  FileVersionsViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileVersionsViewController.h"

@interface FileVersionsViewController ()
@property (strong, nonatomic) ProjectFile *curFile;

@end

@implementation FileVersionsViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileVersionsViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}
@end
