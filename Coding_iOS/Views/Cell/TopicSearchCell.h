//
//  TopicSearchCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectTopic.h"

@interface TopicSearchCell : UITableViewCell
@property (strong, nonatomic) ProjectTopic *curTopic;;
+(CGFloat)cellHeightWithObj:(id)aObj;
@end