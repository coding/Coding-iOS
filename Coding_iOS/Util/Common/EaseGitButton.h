//
//  EaseGitButton.h
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    EaseGitButtonTypeStar = 0,
    EaseGitButtonTypeWatch,
    EaseGitButtonTypeFork
} EaseGitButtonType;

@interface EaseGitButton : UIButton
@property (strong, nonatomic) NSString *normalTitle, *checkedTitle, *normalIcon, *checkedIcon;
@property (nonatomic, assign) NSInteger userNum;
@property (assign, nonatomic) BOOL checked;

- (id)initWithFrame:(CGRect)frame normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon userNum:(NSInteger)userNum checked:(BOOL)checked;
+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame type:(EaseGitButtonType)type;
+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon userNum:(NSInteger)userNum checked:(BOOL)checked;

@end
