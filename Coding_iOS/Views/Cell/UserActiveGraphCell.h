//
//  UserActiveGraphCell.h
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/28.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivenessModel.h"

#define kCellIdentifier_UserActiveGraphCell @"UserActiveGraphCell"

@interface UserActiveGraphCell : UITableViewCell

@property (nonatomic, strong) ActivenessModel *activenessModel;

+ (CGFloat)cellHeight;

@end
