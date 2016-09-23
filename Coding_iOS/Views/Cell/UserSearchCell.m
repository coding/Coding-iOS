//
//  UserSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "UserSearchCell.h"
#import "NSString+Attribute.h"
#import "Login.h"

@interface UserSearchCell ()
@property (strong, nonatomic) UIImageView *userIconView,*timeClockIconView;
@property (strong, nonatomic) UILabel *userNameLabel,*timeLabel;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;

@end

@implementation UserSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kUserSearchCellHeight-40)/2, 40, 40)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, (kUserSearchCellHeight-40)/2-3, kScreen_Width - 66 - 100, 20)];
            _userNameLabel.font = [UIFont systemFontOfSize:17];
            _userNameLabel.textColor = kColor222;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_rightBtn) {
            _rightBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            _rightBtn.frame=CGRectMake(kScreen_Width - 80-10, kUserSearchCellHeight/2-16, 80, 32);
            [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_rightBtn setBackgroundImage:[UIImage imageNamed:@"btn_privateMsg_stranger"] forState:UIControlStateNormal];
            [_rightBtn setBackgroundColor:[UIColor clearColor]];
            [self.contentView addSubview:_rightBtn];
        }
        
        if (!self.timeClockIconView) {
            self.timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(66, kUserSearchCellHeight-12-15, 12, 12)];
            self.timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:self.timeClockIconView];
        }
        
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(66+12+3, kUserSearchCellHeight-12-15, 200, 12)];
            self.timeLabel.font = [UIFont systemFontOfSize:12];
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.timeLabel.textColor = kColor999;
            [self.contentView addSubview:self.timeLabel];
        }

    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_curUser) {
        [_userIconView setImage:[UIImage imageNamed:@"add_user_icon"]];
        _userNameLabel.text = @"";
    }else{
        [_userIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
        _userNameLabel.attributedText=[NSString getAttributeFromText:_curUser.name emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    }
    
    _rightBtn.hidden=[[Login curLoginUser].global_key isEqualToString:_curUser.global_key];
    
    self.timeLabel.text=[NSString stringWithFormat:@"%@ 加入coding",[_curUser.created_at stringDisplay_HHmm]];
    [self configSendingStatusUI];
}

- (void)configSendingStatusUI{
    if (_sendingStatus) {
            [_sendingStatus stopAnimating];
    }
}

- (void)rightBtnClicked:(id)sender{
    if (_rightBtnClickedBlock) {
        _rightBtnClickedBlock(_curUser);
    }
}


@end
