//
//  EaseGitButton.m
//  Coding_iOS
//
//  Created by Ease on 15/3/12.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "EaseGitButton.h"

@interface EaseGitButton ()
@property (strong, nonatomic) UIButton *leftButton, *rightButton;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation EaseGitButton


- (instancetype)initWithFrame:(CGRect)frame
                  normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
                   normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
                normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
            normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
                      userNum:(NSInteger)userNum checked:(BOOL)checked{
    self=[super initWithFrame:frame];
    if(self){
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.0;
        self.layer.borderWidth = 0.5;
        
        CGFloat splitX = floor(CGRectGetWidth(frame) *11/18);
        CGFloat frameHeight = CGRectGetHeight(frame);
        CGFloat fontSize = 11;
        if (kDevice_Is_iPhone6) {
            fontSize = 12;
        }else if (kDevice_Is_iPhone6Plus){
            fontSize = 14;
        }
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(splitX, 0, 1, frameHeight)];
        _lineView.backgroundColor = kColorTableSectionBg;
        [self addSubview:_lineView];
        
        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, splitX, frameHeight)];
        _leftButton.layer.masksToBounds = YES;
        _leftButton.layer.cornerRadius = 2.0;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        _leftButton.imageEdgeInsets = UIEdgeInsetsMake(-1, 0, 1, 0);
        
        [self addSubview:_leftButton];
        
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(splitX, 0, CGRectGetWidth(frame) - splitX, frameHeight)];
        _rightButton.layer.masksToBounds = YES;
        _rightButton.layer.cornerRadius = 2.0;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        
        _rightButton.titleLabel.minimumScaleFactor = 0.5;
        
        [self addSubview:_rightButton];
        
        __weak typeof(self) weakSelf = self;
        [_leftButton bk_addEventHandler:^(id sender) {
            if (weakSelf.buttonClickedBlock) {
                weakSelf.buttonClickedBlock(self, EaseGitButtonPositionLeft);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_rightButton bk_addEventHandler:^(id sender) {
            if (weakSelf.buttonClickedBlock) {
                weakSelf.buttonClickedBlock(self, EaseGitButtonPositionRight);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
        _normalTitle = normalTitle;
        _checkedTitle = checkedTitle? checkedTitle: normalTitle;
        
        _normalIcon = normalIcon;
        _checkedIcon = checkedIcon? checkedIcon: normalIcon;
        
        _normalBGColor = normalBGColor? normalBGColor: [UIColor clearColor];
        _checkedBGColor = checkedBGColor? checkedBGColor: [UIColor clearColor];
        
        _normalBorderColor = normalBorderColor? normalBorderColor: [UIColor clearColor];
        _checkedBorderColor = checkedBorderColor? checkedBorderColor: [UIColor clearColor];
        
        _userNum = userNum;
        _checked = checked;
        
        [self updateContent];
    }
    return self;
}

+ (instancetype)gitButtonWithFrame:(CGRect)frame
                  normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle
                   normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon
                normalBGColor:(UIColor *)normalBGColor checkedBGColor:(UIColor *)checkedBGColor
            normalBorderColor:(UIColor *)normalBorderColor checkedBorderColor:(UIColor *)checkedBorderColor
                      userNum:(NSInteger)userNum checked:(BOOL)checked{
    return [[EaseGitButton alloc] initWithFrame:frame normalTitle:normalTitle checkedTitle:checkedTitle normalIcon:normalIcon checkedIcon:checkedIcon normalBGColor:normalBGColor checkedBGColor:checkedBGColor normalBorderColor:normalBorderColor checkedBorderColor:checkedBorderColor userNum:userNum checked:checked];
}

+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame type:(EaseGitButtonType)type{
    EaseGitButton *button;
    UIColor *normalBGColor = kColorDDD;
    switch (type) {
        case EaseGitButtonTypeStar:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" 收藏" checkedTitle:@" 已收藏" normalIcon:@"git_icon_star_old" checkedIcon:@"git_icon_stared" normalBGColor:normalBGColor checkedBGColor:kColorBrandGreen normalBorderColor:nil checkedBorderColor:nil userNum:0 checked:NO];
            break;
        case EaseGitButtonTypeWatch:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" 关注" checkedTitle:@" 已关注" normalIcon:@"git_icon_watch_old" checkedIcon:@"git_icon_watched" normalBGColor:normalBGColor checkedBGColor:[UIColor colorWithHexString:@"0x4E90BF"] normalBorderColor:nil checkedBorderColor:nil userNum:0 checked:NO];
            break;
        case EaseGitButtonTypeFork:
        default:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" Fork" checkedTitle:@" Fork" normalIcon:@"git_icon_fork_old" checkedIcon:nil normalBGColor:normalBGColor checkedBGColor:normalBGColor normalBorderColor:nil checkedBorderColor:nil userNum:0 checked:NO];
            break;
    }
    button.type = type;
    return button;
}

- (void)updateContent{
    if (_checked) {
        [_leftButton setTitle:_checkedTitle forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:_checkedIcon] forState:UIControlStateNormal];
        
        self.backgroundColor = _checkedBGColor;
        self.layer.borderColor = _checkedBorderColor.CGColor;
    }else{
        [_leftButton setTitle:_normalTitle forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:_normalIcon] forState:UIControlStateNormal];
        
        self.backgroundColor = _normalBGColor;
        self.layer.borderColor = _normalBorderColor.CGColor;
        
    }
    UIColor *titleColor = [UIColor colorWithHexString:!_checked? @"0x222222": @"0xffffff"];
    if (self.type == EaseGitButtonTypeFork) {
        titleColor = kColor222;
    }
    [_leftButton setTitleColor:titleColor forState:UIControlStateNormal];
    [_rightButton setTitleColor:titleColor forState:UIControlStateNormal];
    
    [_rightButton setTitle:[NSString stringWithFormat:@"%ld", (long)_userNum] forState:UIControlStateNormal];
}

#pragma mark Set
- (void)setNormalTitle:(NSString *)normalTitle{
    _normalTitle = normalTitle;
    if (!_checked) {
        [self updateContent];
    }
}

- (void)setNormalIcon:(NSString *)normalIcon{
    _normalIcon = normalIcon;
    if (!_checked) {
        [self updateContent];
    }
}

- (void)setCheckedTitle:(NSString *)checkedTitle{
    _checkedTitle = checkedTitle;
    if (_checked) {
        [self updateContent];
    }
}

- (void)setCheckedIcon:(NSString *)checkedIcon{
    _checkedIcon = checkedIcon;
    if (_checked) {
        [self updateContent];
    }
}

- (void)setUserNum:(NSInteger)userNum{
    _userNum = userNum;
    [self updateContent];
}

- (void)setChecked:(BOOL)checked{
    if (_checked != checked) {
        _checked = checked;
        [self updateContent];
    }
}

@end
