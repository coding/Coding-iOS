//
//  LocalFileCell.h
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_LocalFileCell @"LocalFileCell"

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface LocalFileCell : SWTableViewCell
@property (strong, nonatomic) NSURL *fileUrl;
+ (CGFloat)cellHeight;
@end
