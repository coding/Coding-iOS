//
//  ResetLabelCell.h
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetLabelCell : UITableViewCell

@property (strong, nonatomic) UITextField *labelField;
@property (strong, nonatomic) UIButton *colorBtn;

+ (CGFloat)cellHeight;

@end
