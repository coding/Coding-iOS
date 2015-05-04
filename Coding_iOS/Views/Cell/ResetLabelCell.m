//
//  ResetLabelCell.m
//  Coding_iOS
//
//  Created by zwm on 15/4/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "ResetLabelCell.h"

@implementation ResetLabelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        if (!_labelField) {
            _labelField = [[UITextField alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, (kScreen_Width - kPaddingLeftWidth * 2), 44)];
            _labelField.textColor = [UIColor colorWithHexString:@"0x222222"];
            _labelField.font = [UIFont systemFontOfSize:16];
            _labelField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [self.contentView addSubview:_labelField];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

+ (CGFloat)cellHeight
{
    return 44.0;
}

@end
