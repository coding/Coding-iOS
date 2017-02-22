//
//  ProjectCodeListSearchCell.h
//  Coding_iOS
//
//  Created by Ease on 2017/2/15.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kCellIdentifier_ProjectCodeListSearchCell @"ProjectCodeListSearchCell"

@interface ProjectCodeListSearchCell : UITableViewCell
@property (strong, nonatomic) NSString *filePath, *treePath, *searchText;
+ (CGFloat)cellHeight;

@end
