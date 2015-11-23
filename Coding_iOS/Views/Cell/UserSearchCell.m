//
//  UserSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "UserSearchCell.h"
#import "Coding_NetAPIManager.h"
#import "NSString+Attribute.h"

@interface UserSearchCell ()
@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UILabel *userNameLabel;
@property (strong, nonatomic) UIButton *rightBtn;
@property (strong, nonatomic) UIActivityIndicatorView *sendingStatus;

@end

@implementation UserSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kUserSearchCellHeight-40)/2, 40, 40)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, (kUserSearchCellHeight-40)/2-3, kScreen_Width - 66 - 100, 20)];
            _userNameLabel.font = [UIFont systemFontOfSize:17];
            _userNameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_rightBtn) {
            _rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 80-kPaddingLeftWidth, (kUserSearchCellHeight-30)/2, 80, 32)];
            [_rightBtn addTarget:self action:@selector(rightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_rightBtn setTitle:@"私信" forState:UIControlStateNormal];
            [_rightBtn setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateNormal];
            [_rightBtn setBackgroundColor:[UIColor clearColor]];
            _rightBtn.layer.borderWidth=1;
            _rightBtn.layer.borderColor=[UIColor colorWithHexString:@"0x999999"].CGColor;
            _rightBtn.layer.masksToBounds=TRUE;
            _rightBtn.layer.cornerRadius=3;
            [self.contentView addSubview:_rightBtn];
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
