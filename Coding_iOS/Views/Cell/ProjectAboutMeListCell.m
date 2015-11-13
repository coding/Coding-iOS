//
//  ProjectAboutMeListCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/11.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kIconSize 90
#define kSwapBtnWidth 135
#define kLeftOffset 12
#define kPinSize 18

#import "ProjectAboutMeListCell.h"

@interface ProjectAboutMeListCell ()
@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) UIImageView *projectIconView, *privateIconView, *pinIconView, *setCommonIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *ownerTitleLabel;
@property (nonatomic, strong) UILabel *describeLabel;
@end

@implementation ProjectAboutMeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        if (!_projectIconView) {
            _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftOffset, 10, kIconSize, kIconSize)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }
        
        if (!_projectTitleLabel) {
            _projectTitleLabel = [UILabel new];
            _projectTitleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [UILabel new];
            _ownerTitleLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
        }
        if (!_describeLabel) {
            _describeLabel = [UILabel new];
            _describeLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
            _describeLabel.font = [UIFont systemFontOfSize:14];
            _describeLabel.numberOfLines=2;
            [self.contentView addSubview:_describeLabel];
        }

        if (!_privateIconView) {
            _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
            _privateIconView.hidden = YES;
            [self.contentView addSubview:_privateIconView];
        }
        
        if (!_pinIconView) {
            _pinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_cell_pin"]];
            _pinIconView.hidden = YES;
            [self.contentView addSubview:_pinIconView];
            [_pinIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kPinSize, kPinSize));
                make.left.equalTo(self.projectIconView).offset(5);
                make.top.equalTo(self.projectIconView).offset(6);
            }];
        }
        
        if (!_setCommonIconView) {
            _setCommonIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
            _setCommonIconView.hidden = YES;
            //for test
            _setCommonIconView.backgroundColor=[UIColor greenColor];
            [self.contentView addSubview:_setCommonIconView];
            [_setCommonIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(13, 3));
                make.right.equalTo(self).offset(-15);
                make.bottom.equalTo(self.projectIconView);
            }];
        }


    }
    return self;
}

- (void)setProject:(Project *)project hasSWButtons:(BOOL)hasSWButtons hasBadgeTip:(BOOL)hasBadgeTip hasIndicator:(BOOL)hasIndicator{
    _project = project;
    if (!_project) {
        return;
    }
    //Icon
    [_projectIconView sd_setImageWithURL:[_project.icon urlImageWithCodePathResizeToView:_projectIconView] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    _privateIconView.hidden = _project.is_public.boolValue;
    
    [_privateIconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_privateIconView.hidden?CGSizeZero:CGSizeMake(12, 9));
        make.centerY.equalTo(_projectTitleLabel.mas_centerY);
        make.left.equalTo(_projectIconView.mas_right).offset(kLeftOffset);
    }];
    
    [_projectTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_projectIconView.mas_top);
        make.height.equalTo(@(25));
        make.left.equalTo(_privateIconView.mas_right).offset(_privateIconView.hidden?0:8);
        make.right.lessThanOrEqualTo(self.mas_right);
    }];
    
    [_ownerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.projectTitleLabel);
        make.left.equalTo(self.privateIconView);
        make.bottom.equalTo(_projectIconView.mas_bottom);
    }];
    
    [_describeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.privateIconView);
        make.height.equalTo(@(40));
        make.width.equalTo(@(kScreen_Width-kLeftOffset-kIconSize-kLeftOffset));
        make.top.equalTo(_projectTitleLabel.mas_bottom);
    }];


    //Title & UserName & description
    _projectTitleLabel.text = _project.name;
    _ownerTitleLabel.text = _project.owner_user_name;
    _describeLabel.text=_project.description_mine;
    
    //hasSWButtons
    [self setRightUtilityButtons:hasSWButtons? [self rightButtons]: nil
                 WithButtonWidth:kSwapBtnWidth];
    
    //hasBadgeTip
    if (hasBadgeTip) {
        NSString *badgeTip = @"";
        if (_project.un_read_activities_count && _project.un_read_activities_count.integerValue > 0) {
            if (_project.un_read_activities_count.integerValue > 99) {
                badgeTip = @"99+";
            }else{
                badgeTip = _project.un_read_activities_count.stringValue;
            }
        }
        [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kIconSize, 15)];
    }else{
        [self.contentView removeBadgeTips];
    }
    
    //hasIndicator
    self.accessoryType = hasIndicator? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    _pinIconView.hidden=!_project.pin.boolValue;
    _setCommonIconView.hidden=!hasBadgeTip;
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xe6e6e6": @"0x3bbd79"]
    //                                                 icon:[UIImage imageNamed:_project.pin.boolValue? @"icon_project_cell_pin": @"icon_project_cell_nopin"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xeeeeee": @"0x3bbd79"]
                                                title:_project.pin.boolValue?@"取消常用":@"设置常用" titleColor:[UIColor colorWithHexString:_project.pin.boolValue?@"0x3bbd79":@"0xffffff"]];
    
    return rightUtilityButtons;
}


@end
