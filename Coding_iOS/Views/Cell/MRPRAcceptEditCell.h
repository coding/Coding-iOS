//
//  MRPRAcceptEditCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_MRPRAcceptEditCell @"MRPRAcceptEditCell"

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface MRPRAcceptEditCell : UITableViewCell
@property (strong, nonatomic) UIPlaceHolderTextView *contentTextView;
@property (copy, nonatomic) void(^contentChangedBlock)(NSString *);

+ (CGFloat)cellHeight;

@end
