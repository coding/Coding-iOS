//
//  MRPRDetailCell.h
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kCellIdentifier_MRPRDetailCell @"MRPRDetailCell"

#import <UIKit/UIKit.h>
#import "MRPRBaseInfo.h"

@interface MRPRDetailCell : UITableViewCell
@property (strong, nonatomic) MRPRBaseInfo *curMRPRInfo;
+ (CGFloat)cellHeightWithObj:(id)obj;
@property (nonatomic, copy) void (^loadRequestBlock)(NSURLRequest *curRequest);
@property (nonatomic, copy) void (^cellHeightChangedBlock)();

@end
