//
//  ProjectSettingViewController.h
//  Coding_iOS
//
//  Created by isaced on 15/3/31.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@class Project;

@interface ProjectSettingViewController : UITableViewController

@property (nonatomic, strong) Project *project;

@property (strong, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *projectImageView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *descTextView;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lines;
@property (strong, nonatomic) IBOutlet UIImageView *privateImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *privateIconLeftConstraint;


@end
