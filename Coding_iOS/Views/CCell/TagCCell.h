//
//  TagCCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCCellIdentifier_Tag @"TagCCell"

#import <UIKit/UIKit.h>
#import "TagsManager.h"

@interface TagCCell : UICollectionViewCell
@property (strong, nonatomic) Tag *curTag;
@property (assign, nonatomic) BOOL hasBeenSelected;
+ (CGSize)ccellSizeWithObj:(id)obj;
@end
