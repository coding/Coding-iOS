//
//  ProjectAboutOthersListCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/13.
//  Copyright © 2015年 Coding. All rights reserved.
//

/**
 *  我关注的 我收藏的   只用公开一种状态 不支持侧滑置顶
 */


#define kProjectAboutOthersListCellHeight 104

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "SWTableViewCell.h"

@interface ProjectAboutOthersListCell : SWTableViewCell
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end
