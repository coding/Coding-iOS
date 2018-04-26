//
//  ProjectArchiveViewController.h
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/26.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Project.h"

@interface ProjectArchiveViewController : UITableViewController

@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lines;

@end
