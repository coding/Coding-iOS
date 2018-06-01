//
//  Input_OnlyText_Cell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kCellIdentifier_Input_OnlyText_Cell_Text @"Input_OnlyText_Cell_Text"
#define kCellIdentifier_Input_OnlyText_Cell_Captcha @"Input_OnlyText_Cell_Captcha"
#define kCellIdentifier_Input_OnlyText_Cell_Password @"Input_OnlyText_Cell_Password"
#define kCellIdentifier_Input_OnlyText_Cell_Phone @"Input_OnlyText_Cell_Phone"
#define kCellIdentifier_Input_OnlyText_Cell_Company @"Input_OnlyText_Cell_Company"

#import <UIKit/UIKit.h>
#import "UITapImageView.h"
#import "PhoneCodeButton.h"

@interface Input_OnlyText_Cell : UITableViewCell
@property (strong, nonatomic, readonly) UITextField *textField;
@property (strong, nonatomic) UILabel *countryCodeL;

@property (strong, nonatomic, readonly) PhoneCodeButton *verify_codeBtn;
@property (strong, nonatomic, readonly) UILabel *companySuffixL;

@property (assign, nonatomic) BOOL isBottomLineShow;

@property (nonatomic,copy) void(^textValueChangedBlock)(NSString *);
@property (nonatomic,copy) void(^editDidBeginBlock)(NSString *);
@property (nonatomic,copy) void(^editDidEndBlock)(NSString *);
@property (nonatomic,copy) void(^phoneCodeBtnClckedBlock)(PhoneCodeButton *);
@property (nonatomic,copy) void(^countryCodeBtnClickedBlock)();

- (void)setPlaceholder:(NSString *)phStr value:(NSString *)valueStr;
+ (NSString *)randomCellIdentifierOfPhoneCodeType;
@end
