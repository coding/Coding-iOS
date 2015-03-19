//
//  ProjectItemsCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectItemsCell_Public @"ProjectItemsCell_Public"
#define kCellIdentifier_ProjectItemsCell_Private @"ProjectItemsCell_Private"

#import <UIKit/UIKit.h>
#import "Projects.h"

@interface ProjectItemsCell : UITableViewCell
@property (nonatomic, strong) Project *curProject;
@property (nonatomic, copy) void(^itemClickedBlock)(NSInteger index);

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
