//
//  SettingTextCell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-10-13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_SettingText @"SettingTextCell"

#import <UIKit/UIKit.h>

@interface SettingTextCell : UITableViewCell
@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) NSString *textValue;
@property (copy, nonatomic) void(^textChangeBlock)(NSString *textValue);

- (void)setTextValue:(NSString *)textValue andTextChangeBlock:(void(^)(NSString *textValue))block;

@end
