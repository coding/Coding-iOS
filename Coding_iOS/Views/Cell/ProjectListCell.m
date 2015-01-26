//
//  ProjectListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectListCell_IconHeight 55.0
#define kProjectListCell_ContentLeft (10+kProjectListCell_IconHeight+24)



#import "ProjectListCell.h"

@interface ProjectListCell ()
@property (nonatomic, strong) UIImageView *projectIconView, *privateIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *ownerTitleLabel;
@property (nonatomic, strong) UIImageView *arrowImgView;
@end

@implementation ProjectListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor clearColor];
        if (!_projectIconView) {
            _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kProjectListCell_IconHeight, kProjectListCell_IconHeight)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            _projectIconView.clipsToBounds = YES;
            [self.contentView addSubview:_projectIconView];
        }

        if (!_projectTitleLabel) {
            _projectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 10, 180, 25)];
            _projectTitleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 40, 180, 25)];
            _ownerTitleLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
        }
        if (!_privateIconView) {
            _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
            _privateIconView.hidden = YES;
            [self.contentView addSubview:_privateIconView];
        }
        
        [_privateIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_projectTitleLabel);
            make.centerY.mas_equalTo(_ownerTitleLabel.mas_centerY).offset(1);
        }];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_project) {
        return;
    }
    //Icon
    [_projectIconView sd_setImageWithURL:[_project.icon urlImageWithCodePathResizeToView:_projectIconView] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    _privateIconView.hidden = _project.is_public.boolValue;
    [_ownerTitleLabel setX:(_project.is_public.boolValue? kProjectListCell_ContentLeft: kProjectListCell_ContentLeft+CGRectGetWidth(_privateIconView.frame)+10)];
    //Title & UserName
    _projectTitleLabel.text = _project.name;
    _ownerTitleLabel.text = _project.owner_user_name;
    
    NSString *badgeTip = @"";
    if (_project.un_read_activities_count && _project.un_read_activities_count.integerValue > 0) {
        if (_project.un_read_activities_count.integerValue > 99) {
            badgeTip = @"99+";
        }else{
            badgeTip = _project.un_read_activities_count.stringValue;
        }
    }
    [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kProjectListCell_IconHeight, 15)];
}

+ (CGFloat)cellHeightWithObj:(id)obj;{
    return 75.0;
}
@end
