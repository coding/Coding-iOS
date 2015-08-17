//
//  FileInfoViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileInfoViewController.h"

@interface FileInfoViewController ()
@property (strong, nonatomic) ProjectFile *curFile;

@end

@implementation FileInfoViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileInfoViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}
@end
