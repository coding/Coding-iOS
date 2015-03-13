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
+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon userNum:(NSInteger)userNum checked:(BOOL)checked{
    return [[EaseGitButton alloc] initWithFrame:frame normalTitle:normalTitle checkedTitle:checkedTitle normalIcon:normalIcon checkedIcon:checkedIcon userNum:userNum checked:(BOOL)checked];
}
+ (EaseGitButton *)gitButtonWithFrame:(CGRect)frame type:(EaseGitButtonType)type{
    EaseGitButton *button;
    switch (type) {
        case EaseGitButtonTypeStar:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" 收藏" checkedTitle:@" 已收藏" normalIcon:@"git_icon_star" checkedIcon:@"git_icon_stared" userNum:0 checked:NO];
            break;
        case EaseGitButtonTypeWatch:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" 关注" checkedTitle:@" 已关注" normalIcon:@"git_icon_watch" checkedIcon:@"git_icon_watched" userNum:0 checked:NO];
            break;
        case EaseGitButtonTypeFork:
        default:
            button = [EaseGitButton gitButtonWithFrame:frame normalTitle:@" Fork" checkedTitle:@" Forked" normalIcon:@"git_icon_fork" checkedIcon:@"git_icon_forked" userNum:0 checked:NO];
            break;
    }
    return button;
}
- (id)initWithFrame:(CGRect)frame normalTitle:(NSString *)normalTitle checkedTitle:(NSString *)checkedTitle normalIcon:(NSString *)normalIcon checkedIcon:(NSString *)checkedIcon userNum:(NSInteger)userNum checked:(BOOL)checked{
    self=[super initWithFrame:frame];
    if(self){
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 2.0;
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
        self.backgroundColor = [UIColor colorWithHexString:@"0xf1f1f1"];
        
        CGFloat splitX = CGRectGetWidth(frame) /3 *2;
        CGFloat frameHeight = CGRectGetHeight(frame);
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(splitX, 10, 0.5, frameHeight - 2*10)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xcacaca"];
        [self addSubview:_lineView];

        _leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, splitX, frameHeight)];
        _leftButton.layer.masksToBounds = YES;
        _leftButton.layer.cornerRadius = 2.0;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:_leftButton];

        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(splitX, 0, CGRectGetWidth(frame) - splitX, frameHeight)];
        _rightButton.layer.masksToBounds = YES;
        _rightButton.layer.cornerRadius = 2.0;
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:11];
        
        _rightButton.titleLabel.minimumScaleFactor = 0.5;
        [_rightButton setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];

        [self addSubview:_rightButton];
        
        _leftButton.enabled = _rightButton.enabled = NO;
        
        _normalTitle = normalTitle;
        _normalIcon = normalIcon;
        _checkedTitle = checkedTitle? checkedTitle: normalTitle;
        _checkedIcon = checkedIcon? checkedIcon: normalIcon;
        _userNum = userNum;
        _checked = checked;
        
        [self updateContent];
    }
    return self;
}

- (void)updateContent{
    if (_checked) {
        [_leftButton setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
        [_leftButton setTitle:_checkedTitle forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:_checkedIcon] forState:UIControlStateNormal];
    }else{
        [_leftButton setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
        [_leftButton setTitle:_normalTitle forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:_normalIcon] forState:UIControlStateNormal];
    }
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
