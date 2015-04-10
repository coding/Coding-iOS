//
//  TaskDescriptionCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/20.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "TaskDescriptionCell.h"

@interface TaskDescriptionCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation TaskDescriptionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, (kScreen_Width - 120), 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:16];
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_titleLabel];
        }
    }
    return self;
}

- (void)setTitleStr:(NSString *)title andSpecail:(BOOL)isSpecail{
    _titleLabel.text = title;
    _titleLabel.textColor = [UIColor colorWithHexString:isSpecail? @"0x3bbd79": @"0x222222"];
}

+ (CGFloat)cellHeight{
    return 44.0;
}
@end
