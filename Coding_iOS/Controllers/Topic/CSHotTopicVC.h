//
//  CSHotTopicVC.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/15.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSScrollview.h"

@interface CSHotTopicVC : UIViewController

@end

//普通cell
@interface CSHotTopicCell : UITableViewCell

- (void)updateDisplayByTopic:(id)data;

@end

//title使用
@interface CSHotTopicTitleCell : UITableViewCell

@end

//ad cell
@interface CSHotAdCell : UITableViewCell

@end

