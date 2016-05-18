//
//  CommitListCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_CommitListCell @"CommitListCell"

#import <UIKit/UIKit.h>
#import "Commit.h"

@interface CommitListCell : UITableViewCell
@property (strong, nonatomic) Commit *curCommit;
+ (CGFloat)cellHeight;

@end
