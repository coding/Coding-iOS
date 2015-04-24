//
//  Message_RootViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface Message_RootViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
- (void)refresh;
@end
