//
//  MemberCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-20.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "MemberCell.h"
#import "Login.h"


#define kMemberCell_MaxWidthForName (kScreen_Width - 60 - 100)
#define kMemberCell_FontForName [UIFont systemFontOfSize:17]

@interface MemberCell ()
@property (strong, nonatomic) UIImageView *memberIconView, *creatorIconView;
@property (strong, nonatomic) UILabel *memberNameLabel;
@end

@implementation MemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        if (!_memberIconView) {
            _memberIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MemberCell cellHeight]-40)/2, 40, 40)];
            [_memberIconView doCircleFrame];
            [self.contentView addSubview:_memberIconView];
        }
        if (!_memberNameLabel) {
            _memberNameLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(60, ([MemberCell cellHeight]-30)/2, kMemberCell_MaxWidthForName, 30)];
            _memberNameLabel.font = kMemberCell_FontForName;
            _memberNameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
//            _memberNameLabel.minimumScaleFactor = 0.5;
//            _memberNameLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_memberNameLabel];
        }
        if (!_leftBtn) {
            _leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width - 80-kPaddingLeftWidth, ([MemberCell cellHeight]-30)/2, 80, 32)];
            [_leftBtn addTarget:self action:@selector(leftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_leftBtn];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curMember) {
        return;
    }
    [_memberIconView sd_setImageWithURL:[_curMember.user.avatar urlImageWithCodePathResizeToView:_memberIconView] placeholderImage:kPlaceholderMonkeyRoundView(_memberIconView)];
    if (_curMember.type.intValue == 100) {//项目创建者
        NSString *nameStr = _curMember.user.name;
        CGFloat maxNameWidth = kMemberCell_MaxWidthForName - 30;
        CGFloat nameWidth = [nameStr getWidthWithFont:kMemberCell_FontForName constrainedToSize:CGSizeMake(kScreen_Width, CGFLOAT_MAX)] + 5;
        nameWidth = MIN(nameWidth, maxNameWidth);
        [_memberNameLabel setWidth:nameWidth];
        _memberNameLabel.text = nameStr;
        
        if (!_creatorIconView) {
            _creatorIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"creator_image"]];
            [self.contentView addSubview:_creatorIconView];
        }
        [_creatorIconView setCenter:CGPointMake(CGRectGetMaxX(_memberNameLabel.frame)+CGRectGetMidX(_creatorIconView.bounds)+5, CGRectGetMidY(_memberNameLabel.frame))];
        _creatorIconView.hidden = NO;

    }else{
        [_memberNameLabel setWidth:kMemberCell_MaxWidthForName];
        _memberNameLabel.text = _curMember.user.name;
        _creatorIconView.hidden = YES;
    }
    
    if (_type == ProMemTypeProject) {
        if (_curMember.user_id.intValue != [Login curLoginUser].id.integerValue) {
            //        别人
            [_leftBtn configPriMsgBtnWithUser:_curMember.user fromCell:YES];
            _leftBtn.hidden = NO;
        }else{
            //        自己
            [_leftBtn setImage:[UIImage imageNamed:@"btn_project_quit"] forState:UIControlStateNormal];
            [_leftBtn setTitle:@"- 退出项目" forState:UIControlStateNormal];
            if (_curMember.type.intValue == 100) {//项目创建者
                _leftBtn.hidden = YES;
            }else{
                _leftBtn.hidden = NO;
            }
        }
    }else{
        _leftBtn.hidden = YES;
    }

}

- (void)leftBtnClicked:(id)sender{
    if (self.leftBtnClickedBlock) {
        self.leftBtnClickedBlock(sender);
    }
}

+ (CGFloat)cellHeight{
    return 57;
}
@end
