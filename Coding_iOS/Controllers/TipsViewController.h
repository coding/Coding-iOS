//
//  TipsViewController.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-2.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "BaseViewController.h"
#import "CodingTips.h"
#import "UITTTAttributedLabel.h"

@interface TipsViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate>
@property (strong, nonatomic) CodingTips *myCodingTips;

@end
