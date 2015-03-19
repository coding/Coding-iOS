//
//  ProjectActivityListCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectActivityList @"ProjectActivityListCell"

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "UITapImageView.h"

@interface ProjectActivityListCell : UITableViewCell
@property (nonatomic, strong) UITTTAttributedLabel *actionLabel, *contentLabel;
@property (nonatomic, strong) UITapImageView *userIconView;
@property (copy, nonatomic) void (^htmlItemClickedBlock)(HtmlMediaItem *clickedItem, ProjectActivity *proAct, BOOL isContent);

- (void)configWithProAct:(ProjectActivity *)proAct haveRead:(BOOL)haveRead isTop:(BOOL)top isBottom:(BOOL)bottom;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
