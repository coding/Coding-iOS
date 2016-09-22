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
@property (assign, nonatomic) CGFloat userIconViewWith;
@end


@implementation EaseUserHeaderView

+ (id)userHeaderViewWithUser:(User *)user image:(UIImage *)image{
    if (!user || !image) {
        return nil;
    }
    EaseUserHeaderView *headerView = [[EaseUserHeaderView alloc] init];
    headerView.userInteractionEnabled = YES;
    headerView.contentMode = UIViewContentModeScaleAspectFill;

    headerView.curUser = user;
    headerView.bgImage = image;
    
    [headerView configUI];
    return headerView;
}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    [self updateData];
}

- (void)setBgImage:(UIImage *)bgImage{
    _bgImage = bgImage;
    [self updateData];
}

- (void)setNameBtnClicked:(void (^)())nameBtnClicked{
    _nameBtnClicked = nameBtnClicked;
    if (_nameBtnClicked) {
        [_userSexIconView setImage:[UIImage imageNamed:@"user_info_edit"]];
        _userSexIconView.userInteractionEnabled = _userLabel.userInteractionEnabled = YES;
        [_userSexIconView bk_whenTapped:_nameBtnClicked];
        [_userLabel bk_whenTapped:_nameBtnClicked];
    }else{
        [_userLabel bk_whenTapped:nil];
        [_userSexIconView bk_whenTapped:nil];
    }
}

- (void)configUI{
    if (!_curUser) {
        return;
    }
    if (!_coverView) {//遮罩
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
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
                weakSelf.fansCountBtnClicked();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_fansCountBtn];
    }
    
    if (!_followsCountBtn) {
        _followsCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _followsCountBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_followsCountBtn bk_addEventHandler:^(id sender) {
            if (weakSelf.followsCountBtnClicked) {
                weakSelf.followsCountBtnClicked();
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
                weakSelf.followBtnClicked();
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_followBtn];
    }else{
        _followBtn.hidden = YES;
    }
    
    if (!_userLabel) {
        _userLabel = [[UILabel alloc] init];
        _userLabel.font = [UIFont boldSystemFontOfSize:18];
        _userLabel.textColor = [UIColor whiteColor];
        _userLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_userLabel];
    }
    
    if (!_userIconView) {
        _userIconView = [[UITapImageView alloc] init];
        _userIconView.backgroundColor = kColorTableBG;
        [_userIconView addTapBlock:^(id obj) {
            if (weakSelf.userIconClicked) {
                weakSelf.userIconClicked();
            }
        }];
        [self addSubview:_userIconView];
    }
    
    if (kDevice_Is_iPhone6Plus) {
        _userIconViewWith = 100;
    }else if (kDevice_Is_iPhone6){
        _userIconViewWith = 90;
    }else{
        _userIconViewWith = 75;
    }
    
    if (!_userSexIconView) {
        _userSexIconView = [[UITapImageView alloc] init];
        [_userIconView doBorderWidth:1.0 color:nil cornerRadius:_userIconViewWith/2];
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
            make.size.mas_equalTo(CGSizeMake(128, 39));
            make.centerX.equalTo(self);
        }];

        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_followBtn.mas_top).offset(kScaleFrom_iPhone5_Desgin(-25));
            make.height.mas_equalTo(kScaleFrom_iPhone5_Desgin(20));
        }];
    }else{
        [_userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_fansCountBtn.mas_top).offset(kScaleFrom_iPhone5_Desgin(-20));
            make.height.mas_equalTo(kScaleFrom_iPhone5_Desgin(20));
        }];
    }
    
    [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(_userIconViewWith, _userIconViewWith));
        make.bottom.equalTo(_userLabel.mas_top).offset(-15);
        make.centerX.equalTo(self);
    }];
    
    CGFloat userSexIconViewWidth = (14);
    [_userSexIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(userSexIconViewWidth, userSexIconViewWidth));
        
        make.left.equalTo(_userLabel.mas_right).offset(5);
        make.centerY.equalTo(_userLabel);
    }];
    
//    left, right 只是占位，使名字和性别能居中显示
    UIView *left = [[UIView alloc] init], *right = [[UIView alloc] init];
    [self addSubview:left];
    [self addSubview:right];
    [left mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(right);
        make.left.equalTo(self);
        make.right.equalTo(_userLabel.mas_left);
    }];
    [right mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(_userSexIconView.mas_right);
        make.centerY.equalTo(@[_userLabel, left]);
    }];
    
    [self updateData];
}

- (NSMutableAttributedString*)getStringWithTitle:(NSString *)title andValue:(NSString *)value{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", value, title]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]}
                         range:NSMakeRange(0, value.length)];
    
    [attrString addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor whiteColor]}
                         range:NSMakeRange(value.length+1, title.length)];
    return  attrString;
}

- (void)updateData{
    if (!_userIconView) {
        return;
    }
    self.image = _bgImage;
    [_userIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResize:2* _userIconViewWith] placeholderImage:kPlaceholderMonkeyRoundWidth(54.0)];
    
    [_userSexIconView setImage:[UIImage imageNamed:(_nameBtnClicked != nil? @"user_info_edit"://编辑
                                                    _curUser.sex.intValue == 0? @"n_sex_man_icon"://男
                                                    _curUser.sex.intValue == 1? @"n_sex_woman_icon"://女
                                                    @"")]];//未知
    _userLabel.text = _curUser.name;
    [_userLabel sizeToFit];
    
    [_fansCountBtn setAttributedTitle:[self getStringWithTitle:@"粉丝" andValue:_curUser.fans_count.stringValue] forState:UIControlStateNormal];
    [_followsCountBtn setAttributedTitle:[self getStringWithTitle:@"关注" andValue:_curUser.follows_count.stringValue] forState:UIControlStateNormal];
    
    NSString *imageName;
    if (_curUser.followed.boolValue) {
        if (_curUser.follow.boolValue) {
            imageName = @"n_btn_followed_both";
        }else{
            imageName = @"n_btn_followed_yes";
        }
    }else{
        imageName = @"n_btn_followed_not";
    }
    [_followBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}
- (CGFloat)originalHeight{
    BOOL isMe = [_curUser.global_key isEqualToString:[Login curLoginUser].global_key];
    CGFloat viewHeight = isMe? EaseUserHeaderView_Height_Me: EaseUserHeaderView_Height_Other;
    return viewHeight;
}
@end
