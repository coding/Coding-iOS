//
//  CSTopicCreateVC.h
//  Coding_iOS
//
//  Created by pan Shiyu on 15/7/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "BaseViewController.h"

@interface CSTopicCreateVC : BaseViewController

@property (copy, nonatomic) void(^selectTopicBlock)(NSString *topicName);

+ (void)showATSomeoneWithBlock:(void(^)(NSString *topicName))block;


@end


@interface CSTopicNameCell : UITableViewCell

- (void)showCreateBtn:(BOOL)showCreateBtn;

@end

@interface CSMySearchDisplayController : UISearchDisplayController

@end