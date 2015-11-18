//
//  ProjectPublicListCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/16.
//  Copyright © 2015年 Coding. All rights reserved.
//

/**
 *  项目广场
 */

#define kProjectPublicListCellHeight 114

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "SWTableViewCell.h"

@interface ProjectPublicListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end
