//
//  TaskResourceReferenceCell.h
//  Coding_iOS
//
//  Created by Ease on 16/2/23.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TaskResourceReferenceCell @"TaskResourceReferenceCell"

#import <UIKit/UIKit.h>
#import "ResourceReference.h"

@interface TaskResourceReferenceCell : UITableViewCell
@property (strong, nonatomic) ResourceReferenceItem *item;

@end
