//
//  Input_LeftImgage_Cell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Input_LeftImgage_Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImgView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);

- (IBAction)textValueChanged:(UITextField *)sender;
- (IBAction)editDidBegin:(id)sender;
- (IBAction)editDidEnd:(id)sender;

- (void)configWithImgName:(NSString *)imgStr andPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr;
@end
