//
//  NSObject+DynamicActivityCell.h
//  Coding_iOS
//
//  Created by hardac on 16/3/27.
//  Copyright © 2016年 Coding. All rights reserved.
//

#define kCellIdentifier_DynamicActivityCell @"DynamicActivityCell"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProjectLineNote.h"



@interface DynamicActivityCell:UITableViewCell

@property (strong, nonatomic) ProjectLineNote *curActivity;

- (void)configTop:(BOOL)isTop andBottom:(BOOL)isBottom;

+ (CGFloat)cellHeightWithObj:(id)obj
               contentHeight:(CGFloat)height;

@end
