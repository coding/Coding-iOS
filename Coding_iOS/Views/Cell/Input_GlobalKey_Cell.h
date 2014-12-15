//
//  Input_GlobalKey_Cell.h
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-7.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Input_GlobalKey_Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *myImgView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,copy) void(^textValueChangedBlock)(NSString*);

- (IBAction)textValueChanged:(UITextField *)sender;

- (void)configWithImgName:(NSString *)imgStr andPlaceholder:(NSString *)phStr andValue:(NSString *)valueStr;
@end
