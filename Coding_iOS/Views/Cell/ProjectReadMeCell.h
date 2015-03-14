//
//  ProjectReadMeCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/13.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectReadMeCell @"ProjectReadMeCell"

#import <UIKit/UIKit.h>
#import "Projects.h"

@interface ProjectReadMeCell : UITableViewCell
@property (nonatomic, strong) Project *curProject;
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);
@property (nonatomic, copy) void (^cellHeightChangedBlock)();
+ (CGFloat)cellHeightWithObj:(id)obj;
@end
