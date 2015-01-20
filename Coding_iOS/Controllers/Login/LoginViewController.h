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
@property (strong, nonatomic) TPKeyboardAvoidingTableView *myTableView;
@property (strong, nonatomic) UIView *bottomView;

@property (nonatomic, strong) Login *myLogin;
- (void)goRegisterVC:(id)sender;
@end
