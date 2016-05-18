//
//  TaskCommentCCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/30.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCCellIdentifier_TaskCommentCCell @"TaskCommentCCell"

#import <UIKit/UIKit.h>
#import "HtmlMedia.h"
#import "YLImageView.h"

@interface TaskCommentCCell : UICollectionViewCell
@property (strong, nonatomic) HtmlMediaItem *curMediaItem;
@property (strong, nonatomic) YLImageView *imgView;
+(CGSize)ccellSize;
@end
