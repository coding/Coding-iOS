//
//  TeamTopCell.h
//  Coding_iOS
//
//  Created by Ease on 2016/9/9.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TeamTopCell @"TeamTopCell"

#import <UIKit/UIKit.h>
#import "Team.h"

@interface TeamTopCell : UITableViewCell
@property (strong, nonatomic) Team *curTeam;

+ (CGFloat)cellHeight;

@end
