//
//  LocalFilesViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface LocalFilesViewController : BaseViewController
@property (strong, nonatomic) NSString *projectName;
@property (strong, nonatomic) NSMutableArray *fileList;
@end
