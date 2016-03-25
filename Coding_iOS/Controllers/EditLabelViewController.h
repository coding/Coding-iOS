//
//  EditLabelViewController.h
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@class Project;

@interface EditLabelViewController : BaseViewController
@property (strong, nonatomic) NSArray *orignalTags;
@property (strong, nonatomic) Project *curProject;

@property (copy, nonatomic) void(^tagsSelectedBlock)(EditLabelViewController *vc, NSMutableArray *selectedTags);

@end
