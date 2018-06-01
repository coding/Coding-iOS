//
//  NProjectFileListView.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/5/11.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"
#import "ProjectFile.h"

@interface NProjectFileListView : UIView
@property (weak, nonatomic) UIViewController *containerVC;
- (id)initWithFrame:(CGRect)frame project:(Project *)project folder:(ProjectFile *)folder;
@end
