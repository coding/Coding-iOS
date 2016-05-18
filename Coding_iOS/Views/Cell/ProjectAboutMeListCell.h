//
//  ProjectAboutMeListCell.h
//  Coding_iOS
//
//  Created by jwill on 15/11/11.
//  Copyright © 2015年 Coding. All rights reserved.
//

/**
 *  全部项目 我创建的 我参与的   cell样式     :(1)支持公开/私有 两种状态，(2)支持侧滑，(3)支持置顶标识
 */

#define kProjectAboutMeListCellHeight 104

#import <UIKit/UIKit.h>
#import "Projects.h"
#import "SWTableViewCell.h"

@interface ProjectAboutMeListCell : SWTableViewCell
@property(nonatomic,assign)BOOL openKeywords;
@property(nonatomic,assign)BOOL hidePrivateIcon;
- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator;

@end
