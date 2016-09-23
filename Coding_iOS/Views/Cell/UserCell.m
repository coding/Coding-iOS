//
//  UserCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "UserCell.h"
#import "Coding_NetAPIManager.h"

@interface UserCell ()
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;

@end

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([UserCell cellHeight]-40)/2, 40, 40)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(66, ([UserCell cellHeight]-30)/2, kScreen_Width - 66 - 100, 30)];
            _userNameLabel.font = [UIFont systemFontOfSize:17];
            _userNameLabel.textColor = kColor222;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_rightBtn) {
            _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 80-kPaddingLeftWidth, ([UserCell cellHeight]-30)/2, 80, 32)];
            [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_rightBtn];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_curUser) {
        [_userIconView setImage:[UIImage imageNamed:@"add_user_icon"]];
        _userNameLabel.text = @"添加好友";
    }else{
        [_userIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
        _userNameLabel.text = _curUser.name;
    }
    
    if (_usersType == UsersTypeFriends_Message || _usersType == UsersTypeFriends_At || _usersType == UsersTypeFriends_Transpond) {
        _rightBtn.hidden = YES;
    }else if (_usersType == UsersTypeAddToProject){
        NSString *imageName = _isInProject? @"btn_project_added":@"btn_project_add";
        [_rightBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        _rightBtn.hidden = NO;
    }else{
        _rightBtn.hidden = NO;
        [_rightBtn configFollowBtnWithUser:_curUser fromCell:YES];
    }
    [self configSendingStatusUI];
}

- (void)configSendingStatusUI{
    if (_usersType == UsersTypeAddToProject){
        if (_isQuerying) {
            if (!_sendingStatus) {
                _sendingStatus = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                _sendingStatus.hidesWhenStopped = YES;
                [_rightBtn addSubview:_sendingStatus];
                [_sendingStatus setCenter:CGPointMake(CGRectGetMidX(_rightBtn.bounds), CGRectGetMidY(_rightBtn.bounds))];
            }
            [_sendingStatus startAnimating];
        }else{
            [_sendingStatus stopAnimating];
        }
    }else{
        if (_sendingStatus) {
            [_sendingStatus stopAnimating];
        }
    }
}

- (void)rightBtnClicked:(id)sender{
    if (_leftBtnClickedBlock) {
        _leftBtnClickedBlock(_curUser);
    }else{
        [[Coding_NetAPIManager sharedManager] request_FollowedOrNot_WithObj:_curUser andBlock:^(id data, NSError *error) {
            if (data) {
                _curUser.followed = [NSNumber numberWithBool:!_curUser.followed.boolValue];
                [_rightBtn configFollowBtnWithUser:_curUser fromCell:YES];
            }
        }];
    }
}


+ (CGFloat)cellHeight{
    return 57;
}

@end
