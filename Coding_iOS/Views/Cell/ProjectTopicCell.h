//
//  ProjectTopicCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface ProjectTopicCell : UITableViewCell
@property (strong, nonatomic) ProjectTopic *curTopic;;

+(CGFloat)cellHeightWithObj:(id)aObj;
@end
