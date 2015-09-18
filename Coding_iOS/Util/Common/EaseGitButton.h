//
//  EaseGitButton.h
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, EaseGitButtonType) {
    EaseGitButtonTypeStar = 0,
    EaseGitButtonTypeWatch,
    EaseGitButtonTypeFork
};

typedef NS_ENUM(NSInteger, EaseGitButtonPosition) {
    EaseGitButtonPositionLeft = 0,
    EaseGitButtonPositionRight
};

@interface EaseGitButton : UIButton
@property (strong, nonatomic) NSString *normalTitle, *checkedTitle, *normalIcon, *checkedIcon;
@property (strong, nonatomic) UIColor *normalBGColor, *checkedBGColor, *normalBorderColor, *checkedBorderColor;
@property (nonatomic, assign) NSInteger userNum;
@property (assign, nonatomic) BOOL checked;
@property (assign, nonatomic) EaseGitButtonType type;
@property (copy, nonatomic) void(^buttonClickedBlock)(EaseGitButton *button, EaseGitButtonPosition position);

- (instancetype)initWithFrame:(CGRect)frame
        normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
         normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
      normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
  normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
            userNum:(NSInteger)userNum checked:(BOOL)checked;

+ (instancetype)gitButtonWithFrame:(CGRect)frame
        normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
         normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
      normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
  normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
            userNum:(NSInteger)userNum checked:(BOOL)checked;

+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame type:(EaseGitButtonType)type;

@end
