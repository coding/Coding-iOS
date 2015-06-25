//
//  LoginViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "Login.h"
#import "TPKeyboardAvoidingTableView.h"

@interface LoginViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property (assign, nonatomic) BOOL showDismissButton;
@end
