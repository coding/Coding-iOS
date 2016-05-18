//
//  ProjectAdvancedSettingViewController.h
//  Coding_iOS
//
//  Created by isaced on 15/3/31.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Project;

@interface ProjectAdvancedSettingViewController : UITableViewController

@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lines;

@end
