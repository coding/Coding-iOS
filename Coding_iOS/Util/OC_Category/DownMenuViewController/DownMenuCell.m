//
//  DownMenuCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-24.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "DownMenuCell.h"

@implementation DownMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curItem) {
        return;
    }
    self.imageView.frame = CGRectMake(27, (50.0-25.0)/2, 25, 25);
    self.textLabel.frame = CGRectMake(65, (50.0-25.0)/2, 150, 25);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = kColor222;
    self.textLabel.font = [UIFont systemFontOfSize:15];
    
    self.imageView.image = [UIImage imageNamed:_curItem.imageName];
    self.textLabel.text = _curItem.titleValue;;
}
@end
