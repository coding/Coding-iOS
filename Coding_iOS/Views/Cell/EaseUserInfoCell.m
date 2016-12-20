//
//  EaseUserInfoCell.m
//  Coding_iOS
//
//  Created by 张达棣 on 16/11/28.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "EaseUserInfoCell.h"
#import "UIButton+WebCache.h"
#import "TagsScrollView.h"
#import "Login.h"
#import "UILabel+Common.h"

@interface EaseUserInfoCell ()
@property (nonatomic, strong) UIButton *headIconButton;
@property (nonatomic, strong) UIButton *fansButton; //粉丝
@property (nonatomic, strong) UIButton *followsButton; //关注
@property (nonatomic, strong) UIButton *addFollowsButton; //添加关注
@property (nonatomic, strong) UIButton *messageButton; //发送消息
@property (nonatomic, strong) UILabel *nameLabel; //名字
@property (nonatomic, strong) UIImageView *sexImageView; //性别
@property (nonatomic, strong) UIButton *detailsButton;//详情信息
@property (nonatomic, strong) UIButton *localButton; //地址
@property (nonatomic, strong) TagsScrollView *tagView;  //标签
@property (nonatomic, strong) UILabel *sloganLabel; //个性签名
@property (nonatomic, strong) UIButton *editButtonClick; //编辑资料
@end

@implementation EaseUserInfoCell

#pragma mark - 生命周期方法

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatView];

    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 外部方法

#pragma makr - 消息

#pragma mark - 系统委托

#pragma mark - 自定义委托

#pragma mark - 响应方法

- (void)userIconButtonClicked:(id)sender {
    if (_userIconClicked) {
        _userIconClicked();
    }
}

- (void)fansCountButtonClicked:(id)sender {
    if (_fansCountBtnClicked) {
        _fansCountBtnClicked();
    }
}

- (void)followsCountButtonClicked:(id)sender {
    if (_followsCountBtnClicked) {
        _followsCountBtnClicked();
    }
}

- (void)followButtonClicked:(id)sender {
    if (_followBtnClicked) {
        _followBtnClicked();
    }
}

- (void)editButtonClicked:(id)sender {
    if (_editButtonClicked) {
        _editButtonClicked();
    }
}

- (void)messageButtonClicked:(id)sender {
    if (_messageBtnClicked) {
        _messageBtnClicked();
    }
}

- (void)detailInfoButtonClicked:(id)sender {
    if (_detailInfoBtnClicked) {
        _detailInfoBtnClicked();
    }
}

#pragma mark - 私有方法

- (void)creatView {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headIconButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 20, 77, 77)];
    _headIconButton.cornerRadius = _headIconButton.width / 2;
    _headIconButton.masksToBounds = YES;
    [_headIconButton addTarget:self action:@selector(userIconButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_headIconButton];
    
    _fansButton = [[UIButton alloc] init];
    _fansButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _fansButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_fansButton setTitleColor:[UIColor colorWithRGBHex:0x4f565f] forState:UIControlStateNormal];
    [_fansButton addTarget:self action:@selector(fansCountButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_fansButton];
    _fansButton.sd_layout.leftSpaceToView(self.contentView, 112).topSpaceToView(self.contentView, 30).widthIs(100).heightIs(21);
    
    _followsButton = [[UIButton alloc] init];
    _followsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _followsButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_followsButton setTitleColor:[UIColor colorWithRGBHex:0x4f565f] forState:UIControlStateNormal];
    [_followsButton addTarget:self action:@selector(followsCountButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_followsButton];
    _followsButton.sd_layout.leftSpaceToView(_fansButton, 40).topEqualToView(_fansButton).widthIs(100).heightRatioToView(_fansButton, 1);
    
    _messageButton = [[UIButton alloc] init];
    [_messageButton setImage:[UIImage imageNamed:@"user_info_message"] forState:UIControlStateNormal];
    _messageButton.backgroundColor = [UIColor colorWithRGBHex:0xf2f4f6];
    _messageButton.borderWidth = 1;
    _messageButton.borderColor = [UIColor colorWithRGBHex:0xd8dde4];
    _messageButton.cornerRadius = 2;
    [_messageButton addTarget:self action:@selector(messageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_messageButton];
    _messageButton.sd_layout.rightSpaceToView(self.contentView, 15).topSpaceToView(self.contentView, 59).widthIs(50).heightIs(30);

    
    _addFollowsButton = [[UIButton alloc] init];
    [_addFollowsButton setTitleColor:[UIColor colorWithRGBHex:0x2ebe76] forState:UIControlStateNormal];
    _addFollowsButton.titleLabel.font = [UIFont systemFontOfSize:13];
    _addFollowsButton.borderWidth = 1;
    _addFollowsButton.borderColor = [UIColor colorWithRGBHex:0xd8dde4];
    [_addFollowsButton addTarget:self action:@selector(followButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_addFollowsButton];
    _addFollowsButton.sd_layout.leftSpaceToView(self.contentView, 112).topEqualToView(_messageButton).rightSpaceToView(_messageButton, 5).heightIs(30);

    
    _editButtonClick = [[UIButton alloc] init];
    [_editButtonClick setTitle:@"编辑资料" forState:UIControlStateNormal];
    [_editButtonClick setTitleColor:[UIColor colorWithRGBHex:0x272c33] forState:UIControlStateNormal];
    _editButtonClick.titleLabel.font = [UIFont systemFontOfSize:13];
    _editButtonClick.cornerRadius = 2;
    _editButtonClick.masksToBounds = YES;
    _editButtonClick.borderWidth = 1;
    _editButtonClick.borderColor = [UIColor colorWithRGBHex:0xd8dde4];
    _editButtonClick.backgroundColor = [UIColor colorWithRGBHex:0xf2f4f6];
    [_editButtonClick addTarget:self action:@selector(editButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _editButtonClick.hidden = YES;
    [self.contentView addSubview:_editButtonClick];
    _editButtonClick.sd_layout.leftSpaceToView(self.contentView, 112).topEqualToView(_messageButton).rightSpaceToView(self.contentView, 15).heightIs(30);


    _detailsButton = [[UIButton alloc] init];
    _detailsButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [_detailsButton setTitle:@"详细信息" forState:UIControlStateNormal];
    [_detailsButton setTitleColor:[UIColor colorWithRGBHex:0x76808E] forState:UIControlStateNormal];
    _detailsButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_detailsButton setImage:[UIImage imageNamed:@"register_step_un"] forState:UIControlStateNormal];
    [_detailsButton addTarget:self action:@selector(detailInfoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
     [self.contentView addSubview:_detailsButton];
    _detailsButton.sd_layout.rightSpaceToView(self.contentView, 8).topSpaceToView(_headIconButton, 20).widthIs(80).heightIs(21);
    _detailsButton.imageView.sd_layout.rightEqualToView(_detailsButton).centerYEqualToView( _detailsButton).widthIs(13).heightIs(10);
    _detailsButton.titleLabel.sd_layout.rightSpaceToView(_detailsButton.imageView, 2).centerYEqualToView( _detailsButton).widthIs(60).heightRatioToView(_detailsButton.imageView, 1);
    
    
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor colorWithRGBHex:0x323a45];
    _nameLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.sd_layout.leftSpaceToView(self.contentView, 15).topSpaceToView(_headIconButton, 20).heightIs(24);
    [_nameLabel setSingleLineAutoResizeWithMaxWidth:kScreen_Width / 2];
    
    _sexImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_sexImageView];
    _sexImageView.sd_layout.leftSpaceToView(_nameLabel, 4).centerYEqualToView(_nameLabel).widthIs(16).heightIs(16);
    
    _localButton = [[UIButton alloc] init];
    [_localButton setTitleColor:[UIColor colorWithRGBHex:0x4f565f] forState:UIControlStateNormal];
    _localButton.titleLabel.font = [UIFont systemFontOfSize:14];
    _localButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_localButton setImage:[UIImage imageNamed:@"user_info_locus"] forState:UIControlStateNormal];
    [self.contentView addSubview:_localButton];
    _localButton.sd_layout.leftEqualToView(_nameLabel).topSpaceToView(_nameLabel, 15).rightSpaceToView(self.contentView, 15).heightIs(20);
    _localButton.imageView.sd_layout.leftSpaceToView(_localButton, 0).centerYEqualToView(_localButton).widthIs(15).heightRatioToView(_localButton, .75);
    _localButton.titleLabel.sd_layout.leftSpaceToView(_localButton.imageView, 15).centerYEqualToView(_localButton).heightIs(21).rightSpaceToView(_localButton, 4);

    _tagView = [[TagsScrollView alloc] init];
    _tagView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_tagView];
    
    _sloganLabel = [[UILabel alloc] init];
    _sloganLabel.textColor = [UIColor colorWithRGBHex:0x76808e];
    _sloganLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_sloganLabel];
}

#pragma mark - get/set方法

- (void)setUser:(User *)user {
    _user = user;
    
    if ([Login isLoginUserGlobalKey:user.global_key]) {
        _editButtonClick.hidden = NO;
        _messageButton.hidden = _addFollowsButton.hidden = _detailsButton.hidden = YES;
    }
    
    [_headIconButton sd_setBackgroundImageWithURL:[user.avatar urlImageWithCodePathResize:2* _headIconButton.width] forState:UIControlStateNormal placeholderImage:kPlaceholderMonkeyRoundWidth(54.0)];
    [_fansButton setTitle:[NSString stringWithFormat:@"粉丝  %@", user.fans_count.stringValue] forState:UIControlStateNormal];
    [_fansButton.titleLabel colorTextWithColor:[UIColor colorWithRGBHex:0x76808e] range:NSMakeRange(0, 2)];
    [_fansButton.titleLabel fontTextWithFont:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 2)];
    
    [_followsButton setTitle:[NSString stringWithFormat:@"关注  %@", user.follows_count.stringValue] forState:UIControlStateNormal];
    [_followsButton.titleLabel colorTextWithColor:[UIColor colorWithRGBHex:0x76808e] range:NSMakeRange(0, 2)];
    [_followsButton.titleLabel fontTextWithFont:[UIFont systemFontOfSize:12] range:NSMakeRange(0, 2)];

    NSString *addFollowsButtonImageName, *addFollowsButtonTitle;
    if (user.followed.boolValue) {
        if (user.follow.boolValue) {
            addFollowsButtonImageName = @"user_info_mutualConcern"; //互相关注
            addFollowsButtonTitle = @" 互相关注";
            [_addFollowsButton setTitleColor:[UIColor colorWithRGBHex:0x323a45] forState:UIControlStateNormal];
        }else{
            addFollowsButtonImageName = @"user_info_alreadyConcerned"; //已关注
            addFollowsButtonTitle = @" 已关注";
            [_addFollowsButton setTitleColor:[UIColor colorWithRGBHex:0x323a45] forState:UIControlStateNormal];
        }
    }else{
        addFollowsButtonImageName = @"user_info_addAttention";
        addFollowsButtonTitle = @" 关注";
        [_addFollowsButton setTitleColor:[UIColor colorWithRGBHex:0x2ebe76] forState:UIControlStateNormal];
    }
    [_addFollowsButton setImage:[UIImage imageNamed:addFollowsButtonImageName] forState:UIControlStateNormal];
    [_addFollowsButton setTitle:addFollowsButtonTitle forState:UIControlStateNormal];
    
    _nameLabel.text = user.name;
    if (user.sex.integerValue == 0) {
        _sexImageView.image = [UIImage imageNamed:@"user_info_man"];
    } else if (user.sex.integerValue == 1){
        _sexImageView.image = [UIImage imageNamed:@"user_info_sex"];
    } else {
        _sexImageView.image = nil;
    }
    [_localButton setTitle:user.location forState:UIControlStateNormal];
    _sloganLabel.text = user.slogan;
    _tagView.tags = user.tags_str;
    
    _localButton.hidden = [_user.location isEqualToString:@"未填写"];
    UIView *tempView = !_localButton.hidden ? _localButton : _nameLabel;
    _tagView.sd_resetLayout.leftSpaceToView(self.contentView, 15).topSpaceToView(tempView, 14).rightSpaceToView(self.contentView, 15).heightIs(25);
    
    _tagView.hidden = [_user.tags_str isEqualToString:@"未添加"];
    tempView = !_tagView.hidden ? _tagView : tempView;
    _sloganLabel.sd_resetLayout.leftSpaceToView(self.contentView, 15).topSpaceToView(tempView, 10).rightSpaceToView(self.contentView, 15).autoHeightRatio(0);
    
    _sloganLabel.hidden = [_user.slogan isEqualToString:@"未填写"];
    tempView = !_sloganLabel.hidden ? _sloganLabel : tempView;
    [self setupAutoHeightWithBottomView:tempView bottomMargin:20];
    
}

@end
