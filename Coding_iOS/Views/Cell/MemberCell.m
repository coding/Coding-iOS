//
//  MemberCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "MemberCell.h"
#import "Login.h"



@interface MemberCell ()
@property (strong, nonatomic) UIImageView *memberIconView, *typeIconView;
@property (strong, nonatomic) UILabel *memberNameLabel, *memberAliasLabel;
@end

@implementation MemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_memberIconView) {
            _memberIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MemberCell cellHeight]-40)/2, 40, 40)];
            [_memberIconView doCircleFrame];
            [self.contentView addSubview:_memberIconView];
        }
        if (!_memberNameLabel) {
            _memberNameLabel = [UILabel new];
            _memberNameLabel.font = [UIFont systemFontOfSize:17];
            _memberNameLabel.textColor = kColor222;
            [self.contentView addSubview:_memberNameLabel];
        }
        if (!_typeIconView) {
            _typeIconView = [UIImageView new];
            [self.contentView addSubview:_typeIconView];
            [_typeIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.memberNameLabel.mas_right).offset(10);
                make.centerY.equalTo(self.memberNameLabel);
                make.size.mas_equalTo(CGSizeMake(16, 16));
            }];
        }
        if (!_memberAliasLabel) {
            _memberAliasLabel = [UILabel new];
            _memberAliasLabel.font = [UIFont systemFontOfSize:12];
            _memberAliasLabel.textColor = kColor666;
            [self.contentView addSubview:_memberAliasLabel];
            [_memberAliasLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.memberNameLabel);
                make.height.mas_equalTo(20);
                make.centerY.equalTo(self.contentView).offset(10);
            }];
        }
        if (!_leftBtn) {
            _leftBtn = [UIButton new];
            [_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_leftBtn];
            [_leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 32));
                make.centerY.equalTo(self.contentView);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            }];
        }
    }
    return self;
}

- (void)setCurMember:(ProjectMember *)curMember{
    _curMember = curMember;
    
    if (!_curMember) {
        return;
    }
    [_memberIconView sd_setImageWithURL:[_curMember.user.avatar urlImageWithCodePathResizeToView:_memberIconView] placeholderImage:kPlaceholderMonkeyRoundView(_memberIconView)];
    _memberNameLabel.text = _curMember.user.name;
    if (_curMember.alias.length > 0) {
        _memberAliasLabel.text = _curMember.alias;
        _memberAliasLabel.hidden = NO;
    }else{
        _memberAliasLabel.hidden = YES;
    }
    switch (_curMember.type.integerValue) {
        case 100://项目所有者
        case 90://项目管理员
        case 75://受限成员
        {
            [_typeIconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"member_type_%ld", (long)_curMember.type.integerValue]]];
            _typeIconView.hidden = NO;
        }
            break;
        case 80://普通成员
        default:
        {
            _typeIconView.hidden = YES;
        }
            break;
    }
    
    if (_type == ProMemTypeTaskWatchers || _type == ProMemTypeTopicWatchers) {//「添加、已添加」按钮
        _leftBtn.hidden = NO;
    }else if (_type == ProMemTypeProject){
        if (_curMember.user_id.intValue != [Login curLoginUser].id.integerValue) {//「私信」按钮
            //        别人
            [_leftBtn configPriMsgBtnWithUser:_curMember.user fromCell:YES];
//            _leftBtn.hidden = NO;
            _leftBtn.hidden = YES;//说是不要私信按钮了
        }else{
            //        自己
            if (_curMember.type.intValue == 100) {//项目创建者不能「退出」
                _leftBtn.hidden = YES;
            }else{//「退出」按钮
                [_leftBtn setImage:[UIImage imageNamed:@"btn_project_quit"] forState:UIControlStateNormal];
                [_leftBtn setTitle:@"- 退出项目" forState:UIControlStateNormal];
                _leftBtn.hidden = NO;
            }
        }
    }else{
        _leftBtn.hidden = YES;
    }    
    [_memberNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.memberIconView.mas_right).offset(10);
        make.height.mas_equalTo(20);
        make.centerY.equalTo(self.contentView).offset(_curMember.alias.length > 0? -10: 0);
        if (_leftBtn.hidden) {
            make.right.lessThanOrEqualTo(self.contentView).offset(_typeIconView.hidden? -15: -40);
        }else{
            make.right.lessThanOrEqualTo(_leftBtn.mas_left).offset(_typeIconView.hidden? -10: -35);
        }
    }];
}

- (void)leftBtnClicked:(id)sender{
    if (self.leftBtnClickedBlock) {
        self.leftBtnClickedBlock(sender);
    }
}

+ (CGFloat)cellHeight{
    return 60;
}

- (void)prepareForReuse{
    [_leftBtn stopQueryAnimate];
}
@end
