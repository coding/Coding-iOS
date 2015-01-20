//
//  Input_OnlyText_Cell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-4.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITapImageView.h"

@interface Input_OnlyText_Cell : UITableViewCell
@property (assign, nonatomic) BOOL isCaptcha, isRegister;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UITapImageView *captchaView;
@property (strong, nonatomic) UIImage *captchaImage;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;

@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);
@property (nonatomic,copy) void(^editDidEndBlock)(NSString*);

- (IBAction)editDidBegin:(id)sender;
- (IBAction)editDidEnd:(id)sender;
- (void)configWithPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr;
- (IBAction)textValueChanged:(id)sender;
- (IBAction)clearBtnClicked:(id)sender;

- (void)refreshCaptchaImage;

@end
