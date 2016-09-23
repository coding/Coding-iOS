//
//  ProjectAboutOthersListCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/13.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "ProjectAboutOthersListCell.h"

#define kIconSize 80
#define kSwapBtnWidth 135
#define kLeftOffset 20
#define kPinSize 22


@interface ProjectAboutOthersListCell ()
@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) UIImageView *projectIconView, *privateIconView, *pinIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, strong) UIImageView *starV, *watchV, *forkV;
@property (strong, nonatomic) UILabel *desL, *starL, *watchL, *forkL;
@end


@implementation ProjectAboutOthersListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_projectIconView) {
            _projectIconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, kIconSize, kIconSize)];
            _projectIconView.layer.masksToBounds = YES;
            _projectIconView.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_projectIconView];
        }
        
        if (!_projectTitleLabel) {
            _projectTitleLabel = [UILabel new];
            _projectTitleLabel.textColor = kColor222;
            _projectTitleLabel.font = [UIFont systemFontOfSize:17];
            [self.contentView addSubview:_projectTitleLabel];
        }
        
        if (!_describeLabel) {
            _describeLabel = [UILabel new];
            _describeLabel.textColor = kColor666;
            _describeLabel.font = [UIFont systemFontOfSize:14];
            _describeLabel.numberOfLines=1;
            [self.contentView addSubview:_describeLabel];
        }
        
        if (!_privateIconView) {
            _privateIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_private"]];
            _privateIconView.hidden = YES;
            [self.contentView addSubview:_privateIconView];
        }
        
        if (!_pinIconView) {
            _pinIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_project_cell_setNormal"]];
            _pinIconView.hidden = YES;
            [self.contentView addSubview:_pinIconView];
            [_pinIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(kPinSize, kPinSize));
                make.left.equalTo(self.projectIconView).offset(5);
                make.top.equalTo(self.projectIconView).offset(6);
            }];
        }
        
        if (!_starV) {
            _starV = [[UIImageView alloc] init];
            [self.contentView addSubview:_starV];
        }
        if (!_watchV) {
            _watchV = [[UIImageView alloc] init];
            [self.contentView addSubview:_watchV];
        }
        if (!_forkV) {
            _forkV = [[UIImageView alloc] init];
            [self.contentView addSubview:_forkV];
        }
        
        if (!_starL) {
            _starL = [[UILabel alloc] init];
            _starL.textColor = kColor999;
            _starL.font = [UIFont systemFontOfSize:10];
            [self.contentView addSubview:_starL];
        }
        if (!_watchL) {
            _watchL = [[UILabel alloc] init];
            _watchL.textColor = kColor999;
            _watchL.font = [UIFont systemFontOfSize:10];
            [self.contentView addSubview:_watchL];
        }
        if (!_forkL) {
            _forkL = [[UILabel alloc] init];
            _forkL.textColor = kColor999;
            _forkL.font = [UIFont systemFontOfSize:10];
            [self.contentView addSubview:_forkL];
        }
        _starV.image = [UIImage imageNamed:@"git_icon_star"];
        _watchV.image = [UIImage imageNamed:@"git_icon_watch"];
        _forkV.image = [UIImage imageNamed:@"git_icon_fork"];

        
        [_starV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_projectIconView);
            make.left.equalTo(_privateIconView);
            make.centerY.equalTo(@[_starL, _watchV, _watchL, _forkV, _forkL]);
            make.width.height.equalTo(@[_watchV, _forkV, @12]);
        }];
        [_starL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_starV.mas_right).offset(2);
            make.height.equalTo(@[_starV, _watchL, _forkL]);
        }];
        [_watchV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_starL.mas_right).offset(10);
        }];
        [_watchL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchV.mas_right).offset(2);
        }];
        [_forkV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_watchL.mas_right).offset(10);
        }];
        [_forkL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_forkV.mas_right).offset(2);
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
    
    [_privateIconView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_privateIconView.hidden?CGSizeZero:CGSizeMake(12, 12));
        make.centerY.equalTo(_projectTitleLabel.mas_centerY);
        make.left.equalTo(_projectIconView.mas_right).offset(kLeftOffset);
    }];
    
    [_projectTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_projectIconView.mas_top);
        make.height.equalTo(@(20));
        make.left.equalTo(_privateIconView.mas_right).offset(_privateIconView.hidden?0:8);
        make.right.lessThanOrEqualTo(self.mas_right).offset(-12);
    }];
    
    [_describeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.privateIconView);
        make.height.equalTo(@(38));
        make.width.equalTo(@(kScreen_Width-kLeftOffset-kIconSize-20));
        make.top.equalTo(_projectTitleLabel.mas_bottom);
    }];
    
    
    //Title  & description & star & watch &fork
    _projectTitleLabel.text = _project.name;
    _describeLabel.text=_project.description_mine;
    _starL.text = _project.star_count.stringValue;
    _watchL.text = _project.watch_count.stringValue;
    _forkL.text = _project.fork_count.stringValue;

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
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    //    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xe6e6e6": @"0x3bbd79"]
    //                                                 icon:[UIImage imageNamed:_project.pin.boolValue? @"icon_project_cell_pin": @"icon_project_cell_nopin"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:_project.pin.boolValue? kColorTableSectionBg: kColorBrandGreen
                                                title:_project.pin.boolValue?@"取消常用":@"设置常用"
                                           titleColor:_project.pin.boolValue? kColorBrandGreen: [UIColor whiteColor]];

//    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithHexString:_project.pin.boolValue? @"0xeeeeee": @"0x3bbd79"]
//                                                title:_project.pin.boolValue?@"取消常用":@"设置常用" titleColor:[UIColor colorWithHexString:_project.pin.boolValue?@"0x3bbd79":@"0xffffff"]];
    
    return rightUtilityButtons;
}

-(void)showSliderAction
{
    NSLog(@"tap");
    [self showRightUtilityButtonsAnimated:TRUE];
}

@end
