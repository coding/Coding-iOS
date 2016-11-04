//
//  TaskDescriptionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TaskDescriptionCell.h"

@interface TaskDescriptionCell ()
@property (strong, nonatomic) UIButton *button;
@end

@implementation TaskDescriptionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_button) {
            _button = [[UIButton alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([[self class] cellHeight] - 40)/2, kScreen_Width - 2*kPaddingLeftWidth, 40)];
            _button.titleLabel.font = [UIFont systemFontOfSize:16];
            _button.backgroundColor = kColorTableSectionBg;
            _button.layer.masksToBounds = YES;
            _button.layer.cornerRadius = 2.0;
            [_button setImage:[UIImage imageNamed:@"task_icon_arrow"] forState:UIControlStateNormal];

            _button.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
            _button.imageEdgeInsets = UIEdgeInsetsMake(0, 70, 0, -70);
            [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_button];
        }
    }
    return self;
}

- (void)setTitleStr:(NSString *)title andSpecail:(BOOL)isSpecail{
    [_button setTitle:title forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor colorWithHexString:isSpecail? @"0x3bbd79": @"0x222222"] forState:UIControlStateNormal];
}

- (void)buttonClicked:(id)sender{
    if (self.buttonClickedBlock) {
        self.buttonClickedBlock();
    }
}

+ (CGFloat)cellHeight{
    return 70.0;
}
@end
