//
//  EditLabelHeadCell.h
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditLabelHeadCell : UITableViewCell

@property (strong, nonatomic) UIButton *addBtn, *colorBtn;
@property (strong, nonatomic) UITextField *labelField;

+ (CGFloat)cellHeight;

@end
