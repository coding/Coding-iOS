//
//  ProjectListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-11.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectListCell_IconHeight 55.0
#define kProjectListCell_ContentLeft (kPaddingLeftWidth+kProjectListCell_IconHeight+20)

#import "ProjectListCell.h"

#ifdef Target_Enterprise

@interface ProjectListCell ()
@property (nonatomic, strong) Project *project;

@property (nonatomic, strong) UIImageView *projectIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *rightL;
@property (nonatomic, strong) UIButton *sliderBtn;
@end

@implementation ProjectListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_projectIconView) {
            _projectIconView = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kProjectListCell_IconHeight, kProjectListCell_IconHeight)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }
        
        if (!_projectTitleLabel) {
            _projectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 10, 180, 25)];
            _projectTitleLabel.textColor = kColor222;
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_rightL) {
            _rightL = [UILabel new];
            _rightL.textAlignment = NSTextAlignmentRight;
            _rightL.textColor = kColorDark7;
            _rightL.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_rightL];
            [_rightL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_projectTitleLabel);
                make.right.equalTo(self.contentView).offset(-10);
            }];
        }
        
        [_projectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView.mas_left).offset(kProjectListCell_ContentLeft);
            make.right.lessThanOrEqualTo(self.contentView).offset(0);
        }];
        if (!_sliderBtn) {
            _sliderBtn = [UIButton new];
            _sliderBtn.hidden = YES;
            //for test
            [_sliderBtn setImage:[UIImage imageNamed:@"btn_setFrequent"] forState:UIControlStateNormal];
            [self.contentView addSubview:_sliderBtn];
            [_sliderBtn addTarget:self action:@selector(showSliderAction) forControlEvents:UIControlEventTouchUpInside];
            [_sliderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(40, 40));
                make.right.equalTo(self.contentView);
                make.bottom.equalTo(self.contentView).offset(5);
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
    //Title & UserName
    _projectTitleLabel.text = _project.name;
    
    //hasSWButtons
    [self setRightUtilityButtons:hasSWButtons? [self rightButtons]: nil
                 WithButtonWidth:[[self class] cellHeight]];
    
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
        [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kProjectListCell_IconHeight, 15)];
    }else{
        [self.contentView removeBadgeTips];
    }
    
    //hasIndicator
    self.accessoryType = hasIndicator? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
    _rightL.hidden = YES;
}

- (void)setProjectRole:(ProjectRole *)curRole{
    [self setProject:curRole.project hasSWButtons:NO hasBadgeTip:NO hasIndicator:YES];
    static NSDictionary *typeDict = nil;
    if (!typeDict) {
        typeDict = @{@(-1): @"",
                     @90: @"管理员",
                     @80: @"普通成员",
                     @75: @"受限成员"};
    }
    _rightL.hidden = NO;
    _rightL.text = typeDict[curRole.type];
}

- (void)setHasDeleteBtn:(BOOL)hasDeleteBtn{
    _hasDeleteBtn = hasDeleteBtn;
    [self setRightUtilityButtons:hasDeleteBtn? [self deleteSWButtons]: nil WithButtonWidth:[[self class] cellHeight]];
    _sliderBtn.hidden = !hasDeleteBtn;
}

- (NSArray *)deleteSWButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
    return rightUtilityButtons;
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xe6e6e6": @"0x0060FF"]
                                                title:_project.pin.boolValue?@"取消常用":@"设置常用" titleColor:[UIColor colorWithHexString:_project.pin.boolValue?@"0x0060FF":@"0xffffff"]];
    
    return rightUtilityButtons;
}

-(void)showSliderAction{
    [self showRightUtilityButtonsAnimated:YES];
}

+ (CGFloat)cellHeight{
    return 75.0;
}
@end

#else

@interface ProjectListCell ()
@property (nonatomic, strong) Project *project;

@property (nonatomic, strong) UIImageView *projectIconView, *privateIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *ownerTitleLabel;
@end

@implementation ProjectListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_projectIconView) {
            _projectIconView = [[YLImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kProjectListCell_IconHeight, kProjectListCell_IconHeight)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }

        if (!_projectTitleLabel) {
            _projectTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 10, 180, 25)];
            _projectTitleLabel.textColor = kColor222;
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectListCell_ContentLeft, 40, 180, 25)];
            _ownerTitleLabel.textColor = kColor999;
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
        }
        if (!_privateIconView) {
            _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
            _privateIconView.hidden = YES;
            [self.contentView addSubview:_privateIconView];
        }
        
        [_projectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(10);
            make.height.mas_equalTo(25);
            make.left.equalTo(self.contentView.mas_left).offset(kProjectListCell_ContentLeft);
            make.right.lessThanOrEqualTo(self.contentView).offset(0);
        }];
        [_ownerTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.equalTo(self.projectTitleLabel);
            make.top.equalTo(self.projectTitleLabel.mas_bottom).offset(5);
        }];
        [_privateIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_projectTitleLabel);
            make.centerY.mas_equalTo(_ownerTitleLabel.mas_centerY).offset(1);
        }];
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
    
    [_ownerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.projectTitleLabel.mas_left).offset(_project.is_public.boolValue? 0: CGRectGetWidth(_privateIconView.frame)+10);
    }];
    //Title & UserName
    _projectTitleLabel.text = _project.name;
    _ownerTitleLabel.text = _project.owner_user_name;
    
    //hasSWButtons
    [self setRightUtilityButtons:hasSWButtons? [self rightButtons]: nil
                 WithButtonWidth:135];
    
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
        [self.contentView addBadgeTip:badgeTip withCenterPosition:CGPointMake(10+kProjectListCell_IconHeight, 15)];
    }else{
        [self.contentView removeBadgeTips];
    }
    
    //hasIndicator
    self.accessoryType = hasIndicator? UITableViewCellAccessoryDisclosureIndicator: UITableViewCellAccessoryNone;
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xe6e6e6": @"0x0060FF"]
//                                                 icon:[UIImage imageNamed:_project.pin.boolValue? @"icon_project_cell_pin": @"icon_project_cell_nopin"]];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xe6e6e6": @"0x0060FF"]
                                                title:_project.pin.boolValue?@"取消常用":@"设置常用" titleColor:[UIColor colorWithHexString:_project.pin.boolValue?@"0x0060FF":@"0xffffff"]];

    return rightUtilityButtons;
}

+ (CGFloat)cellHeight{
    return 75.0;
}
@end

#endif
