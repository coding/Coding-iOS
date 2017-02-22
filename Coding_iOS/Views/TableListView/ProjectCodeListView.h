//
//  ProjectCodeListView.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CodeTree.h"
#import "Projects.h"

@interface ProjectCodeListView : UIView
@property (copy, nonatomic) void (^codeTreeFileOfRefBlock)(CodeTree_File *, NSString *);
@property (copy, nonatomic) void (^codeTreeChangedBlock)(CodeTree *);

- (id)initWithFrame:(CGRect)frame project:(Project *)project andCodeTree:(CodeTree *)codeTree;
- (void)refreshToQueryData;

- (void)createFileClicked;
- (void)uploadImageClicked;

@end
