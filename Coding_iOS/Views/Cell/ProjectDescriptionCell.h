//
//  ProjectDescriptionCell.h
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_ProjectDescriptionCell @"ProjectDescriptionCell"


#import <UIKit/UIKit.h>
#import "Projects.h"

@interface ProjectDescriptionCell : UITableViewCell

- (void)setDescriptionStr:(NSString *)descriptionStr;

+ (CGFloat)cellHeightWithObj:(id)obj;

@end
