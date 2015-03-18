//
//  EaseUserHeaderView.m
//  Coding_iOS
//
//  Created by Ease on 15/3/17.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define EaseUserHeaderView_Height_Me kScaleFrom_iPhone5_Desgin(190)
#define EaseUserHeaderView_Height_Other kScaleFrom_iPhone5_Desgin(250)


#import "EaseUserHeaderView.h"
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>

@interface EaseUserHeaderView ()

@property (strong, nonatomic) UITapImageView *userIconView, *userSexIconView;
@property (strong, nonatomic) UILabel *userLabel;
@property (strong, nonatomic) UIButton *fansCountBtn, *followsCountBtn, *followBtn;
@property (strong, nonatomic) UIView *splitLine, *coverView;
@end


@implementation EaseUserHeaderView

+ (id)userHeaderViewWithUser:(User *)user image:(UIImage *)image{
    if (!user || !image) {
        return nil;
    }
    EaseUserHeaderView *headerView = [[EaseUserHeaderView alloc] init];
    headerView.curUser = user;
//    headerView.bgImage = [image applyLightEffectAtFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    headerView.bgImage = image;
    headerView.contentMode = UIViewContentModeScaleAspectFill;
    
    [headerView updateUI];
    return headerView;
}

- (void)updateUI{
    if (!_curUser) {
        return;
    }
    if (!_coverView) {//遮罩
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addSubview:_coverView];
        [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    BOOL isMe = [_curUser.global_key isEqualToString:[Login curLoginUser].global_key];
    CGFloat viewHeight = isMe? EaseUserHeaderView_Height_Me: EaseUserHeaderView_Height_Other;
    [self setFrame:CGRectMake(0, 0, kScreen_Width, viewHeight)];
    __weak typeof(self) weakSelf = self;
    
    if (!_fansCountBtn) {
        _fansCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fansCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_fansCountBtn bk_addEventHandler:^(id sender) {
            if (weakSelf.fansCountBtnClicked) {
                weakSelf.fansCountBtnClicked(weakSelf);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fansCountBtn];
    }
    
    if (!_followsCountBtn) {
        _followsCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _followsCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_followsCountBtn bk_addEventHandler:^(id sender) {
            if (weakSelf.followsCountBtnClicked) {
                weakSelf.followsCountBtnClicked(weakSelf);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followsCountBtn];
    }
    
    if (!_splitLine) {
        _splitLine = [[UIView alloc] init];
        _splitLine.backgroundColor = [UIColor colorWithHexString:@"0xcacaca"];
        [self addSubview:_splitLine];
    }
    
    if (!isMe && !_followBtn) {
        _followBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followBtn bk_addEventHandler:^(id sender) {
            if (weakSelf.followBtnClicked) {
                weakSelf.followBtnClicked(weakSelf);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followBtn];
    }else{
        _followBtn.hidden = YES;
    }
    
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] init];
        _userLabel.font = [UIFont systemFontOfSize:18];
        _userLabel.textColor = [UIColor whiteColor];
        _userLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_userLabel];
    }
    
    if (!_userIconView) {
        _userIconView = [[UITapImageView alloc] init];
        [_userIconView addTapBlock:^(id obj) {
            if (weakSelf.userIconClicked) {
                weakSelf.userIconClicked(weakSelf);
            }
        }];
        [self addSubview:_userIconView];

    }
    
    CGFloat userIconViewWith = kScaleFrom_iPhone5_Desgin(80);
    if (!_userSexIconView) {
        _userSexIconView = [[UITapImageView alloc] init];
        [_userIconView doBorderWidth:1.0 color:nil cornerRadius:kScaleFrom_iPhone5_Desgin(80)/2];
        [self addSubview:_userSexIconView];
    }
    
    [_fansCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(_splitLine.mas_left).offset(kScaleFrom_iPhone5_Desgin(-15));
        make.bottom.equalTo(self.mas_bottom).offset(kScaleFrom_iPhone5_Desgin(-15));
    }];
    
    [_followsCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.left.equalTo(_splitLine.mas_right).offset(kScaleFrom_iPhone5_Desgin(15));
        make.height.equalTo(@[_fansCountBtn.mas_height, @kScaleFrom_iPhone5_Desgin(20)]);
    }];

    [_splitLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(@[_fansCountBtn, _followsCountBtn]);
        make.size.mas_equalTo(CGSizeMake(0.5, 15));
    }];
    
    if (!isMe) {
        [_followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_fansCountBtn.mas_top).offset(-20);
            make.size.mas_equalTo(CGSizeMake(80, 130));
            make.centerX.equalTo(self);
        }];

        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_followBtn.mas_top).offset(kScaleFrom_iPhone5_Desgin(-15));
            make.height.mas_equalTo(kScaleFrom_iPhone5_Desgin(20));
            make.left.right.equalTo(self);
        }];
    }else{
        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_fansCountBtn.mas_top).offset(kScaleFrom_iPhone5_Desgin(-15));
            make.height.mas_equalTo(kScaleFrom_iPhone5_Desgin(20));
            make.left.right.equalTo(self);
        }];
    }
    
    [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(userIconViewWith, userIconViewWith));
        make.bottom.equalTo(_userLabel.mas_top).offset(-15);
        make.centerX.equalTo(self);
    }];
    
    [_userSexIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.centerX.equalTo(_userIconView.mas_centerX).offset(0.35* userIconViewWith);
        make.centerY.equalTo(_userIconView.mas_centerY).offset(-0.35* userIconViewWith);
    }];
    
    self.image = _bgImage;
    [_userIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResize:2* kScaleFrom_iPhone5_Desgin(80)] placeholderImage:kPlaceholderMonkeyRoundWidth(54.0)];
    if (_curUser.sex.intValue == 0) {
        //        男
        [_userSexIconView setImage:[UIImage imageNamed:@"sex_man_icon"]];
        _userSexIconView.hidden = NO;
    }else if (_curUser.sex.intValue == 1){
        //        女
        [_userSexIconView setImage:[UIImage imageNamed:@"sex_woman_icon"]];
        _userSexIconView.hidden = NO;
    }else{
        //        未知
        _userSexIconView.hidden = YES;
    }
    _userLabel.text = _curUser.name;
    if (!isMe) {
        [_followBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    [_fansCountBtn setAttributedTitle:[self getStringWithTitle:@"粉丝" andValue:_curUser.fans_count.stringValue] forState:UIControlStateNormal];
    [_followsCountBtn setAttributedTitle:[self getStringWithTitle:@"关注" andValue:_curUser.follows_count.stringValue] forState:UIControlStateNormal];
    
    NSString *imageName;
    if (_curUser.followed.boolValue) {
        if (_curUser.follow.boolValue) {
            imageName = @"btn_followed_both";
        }else{
            imageName = @"btn_followed_yes";
        }
    }else{
        imageName = @"btn_followed_not";
    }
    [_followBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];

}

- (NSMutableAttributedString*)getStringWithTitle:(NSString *)title andValue:(NSString *)value{
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", value, title]];
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]}
                         range:NSMakeRange(0, value.length)];
    
    [attriString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]}
                         range:NSMakeRange(value.length+1, title.length)];
    return  attriString;
}

@end
