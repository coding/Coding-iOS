//
//  EditLabelCell.h
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "SWTableViewCell.h"

@interface EditLabelCell : SWTableViewCell

@property (strong, nonatomic) UIButton *selectBtn;
@property (strong, nonatomic) UILabel *nameLbl;

- (void)showRightBtn:(BOOL)show;
- (void)resetLbl;

+ (CGFloat)cellHeight;

@end
