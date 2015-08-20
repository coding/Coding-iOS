//
//  FileInfoViewController.m
//  Coding_iOS
//
//  Created by Ease on 15/8/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileInfoViewController.h"

@interface FileInfoViewController ()
@property (strong, nonatomic) ProjectFile *curFile;

@property (weak, nonatomic) IBOutlet UILabel *finenameL;
@property (weak, nonatomic) IBOutlet UILabel *numL;
@property (weak, nonatomic) IBOutlet UILabel *typeL;
@property (weak, nonatomic) IBOutlet UILabel *sizeL;
@property (weak, nonatomic) IBOutlet UILabel *createL;
@property (weak, nonatomic) IBOutlet UILabel *updateL;
@property (weak, nonatomic) IBOutlet UILabel *createUserL;
@end

@implementation FileInfoViewController
+ (instancetype)vcWithFile:(ProjectFile *)file{
    FileInfoViewController *vc = [self new];
    vc.curFile = file;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"文件信息";
    self.finenameL.text = _curFile.name;
    self.numL.text = [NSString stringWithFormat:@"#%@", _curFile.number.stringValue];
    self.typeL.text = [NSString stringWithFormat:@".%@", _curFile.fileType];
    self.sizeL.text = [NSString sizeDisplayWithByte:_curFile.size.floatValue];
    self.createL.text = [_curFile.created_at stringTimesAgo];
    self.updateL.text = [_curFile.updated_at stringTimesAgo];
    self.createUserL.text = _curFile.owner.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
