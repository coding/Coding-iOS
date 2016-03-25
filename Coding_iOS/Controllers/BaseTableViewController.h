//
//  BaseTableViewController.h
//  UISearchController&UISearchDisplayController
//
//  Created by zml on 15/12/2.
//  Copyright © 2015年 zml@lanmaq.com. All rights reserved.
//  https://github.com/Lanmaq/iOS_HelpOther_WorkSpace


#import <UIKit/UIKit.h>
@class DemoModel,DemoCell;

extern NSString *const kCellIdentifier;

@interface BaseTableViewController : UITableViewController

- (void)configureCell:(DemoCell *)cell forModel:(DemoModel *)model;

@end
