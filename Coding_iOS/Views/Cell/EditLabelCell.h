//
//  EditLabelCell.h
//  Coding_iOS
//
//  Created by zwm on 15/4/16.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "SWTableViewCell.h"
#import "ProjectTag.h"

@interface EditLabelCell : SWTableViewCell
@property (strong, nonatomic) UIButton *selectBtn;

- (void)setTag:(ProjectTag *)curTag andSelected:(BOOL)selected;

+ (CGFloat)cellHeight;

@end
