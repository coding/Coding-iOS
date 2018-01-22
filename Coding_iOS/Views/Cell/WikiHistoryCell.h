//
//  WikiHistoryCell.h
//  Coding_Enterprise_iOS
//
//  Created by Easeeeeeeeee on 2017/4/10.
//  Copyright © 2017年 Coding. All rights reserved.
//
#define kCellIdentifier_WikiHistoryCell @"WikiHistoryCell"

#import <UIKit/UIKit.h>
#import "EAWiki.h"

@interface WikiHistoryCell : UITableViewCell
@property (strong, nonatomic) EAWiki *curWiki;

+ (CGFloat)cellHeightWithObj:(EAWiki *)obj;
@end
