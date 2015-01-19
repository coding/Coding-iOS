//
//  Input_GlobalKey_Cell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-7.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "Input_GlobalKey_Cell.h"

@implementation Input_GlobalKey_Cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configWithImgName:(NSString *)imgStr andPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr{
    self.myImgView.image = [UIImage imageNamed:imgStr];
    self.textField.placeholder = phStr;
    self.textField.text = valueStr;
}

- (IBAction)textValueChanged:(UITextField *)sender {
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(self.textField.text);
    }
}

#pragma mark - UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView = nil;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.frame = CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, self.contentView.frame.size.height);
    self.contentView.layer.borderColor = [[UIColor colorWithHexString:@"0x999999" andAlpha:0.5] CGColor];
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.cornerRadius = 22;
    self.contentView.layer.masksToBounds = YES;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}


@end
