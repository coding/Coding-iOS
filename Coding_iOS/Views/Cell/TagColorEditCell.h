//
//  TagColorEditCell.h
//  Coding_iOS
//
//  Created by Ease on 16/2/19.
//  Copyright © 2016年 Coding. All rights reserved.
//
#define kCellIdentifier_TagColorEditCell @"TagColorEditCell"

#import <UIKit/UIKit.h>

@interface TagColorEditCell : UITableViewCell
@property (strong, nonatomic) UIButton *randomBtn;
@property (strong, nonatomic) UIView *colorView;
@property (strong, nonatomic) UITextField *colorF;
@end
