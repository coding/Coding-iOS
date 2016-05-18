//
//  MRPRCommentCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_MRPRCommentCell @"MRPRCommentCell"
#define kCellIdentifier_MRPRCommentCell_Media @"MRPRCommentCell_Media"

#import <UIKit/UIKit.h>
#import "ProjectLineNote.h"

@interface MRPRCommentCell : UITableViewCell
@property (strong, nonatomic) ProjectLineNote *curItem;
@property (strong, nonatomic) UITTTAttributedLabel *contentLabel;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
