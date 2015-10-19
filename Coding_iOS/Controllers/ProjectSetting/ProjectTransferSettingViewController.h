//
//  ProjectTransferSettingViewController.h
//  Coding_iOS
//
//  Created by Ease on 15/10/19.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Project;

@interface ProjectTransferSettingViewController : UITableViewController
@property (nonatomic, strong) Project *project;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lines;
@end
