//
//  CommitContentCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_CommitContentCell @"CommitContentCell"

#import <UIKit/UIKit.h>
#import "CommitInfo.h"

@interface CommitContentCell : UITableViewCell
@property (strong, nonatomic) CommitInfo *curCommitInfo;
+ (CGFloat)cellHeightWithObj:(id)obj;

@end
 