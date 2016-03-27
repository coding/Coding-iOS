//
//  NSObject+DynamicCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/27.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_DynamicCommentCell @"DynamicCommentCell"
#define kCellIdentifier_DynamicCommentCell_Media @"DynamicCommentCell_Media"

#import <UIKit/UIKit.h>
#import "TaskComment.h"
#import "ProjectLineNote.h"

@interface DynamicCommentCell : UITableViewCell
@property (strong, nonatomic) ProjectLineNote *curComment;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;
- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end