//
//  NewProjectViewController.h
//  Coding_iOS
//
//  Created by isaced on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface NewProjectViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIImageView *projectImageView;
@property (strong, nonatomic) IBOutlet UITextField *projectNameTextField;
@property (strong, nonatomic) IBOutlet UILabel *projectTypeLabel;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *descTextView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lines;
@property (weak, nonatomic) IBOutlet UISwitch *readmeSwitch;

@end
