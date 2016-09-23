//
//  ProjectAboutMeListCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/11.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kIconSize 80
#define kSwapBtnWidth 135
#define kLeftOffset 20
#define kPinSize 22

#import "ProjectAboutMeListCell.h"
#import "NSString+Attribute.h"

@interface ProjectAboutMeListCell ()
@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) UIImageView *projectIconView, *privateIconView, *pinIconView;
@property (nonatomic, strong) UIButton *setCommonBtn;
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
        if (!_ownerTitleLabel) {
            _ownerTitleLabel = [UILabel new];
            _ownerTitleLabel.textColor = kColor999;
            _ownerTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_ownerTitleLabel];
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
                make.right.equalTo(self.projectIconView).offset(-5);
                make.top.equalTo(self.projectIconView).offset(6);
            }];
        }
        
        if (!_setCommonBtn) {
            _setCommonBtn = [UIButton new];
            _setCommonBtn.hidden = YES;
            //for test
            [_setCommonBtn setImage:[UIImage imageNamed:@"btn_setFrequent"] forState:UIControlStateNormal];
            [self.contentView addSubview:_setCommonBtn];
            [_setCommonBtn addTarget:self action:@selector(showSliderAction) forControlEvents:UIControlEventTouchUpInside];
            [_setCommonBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(35, 20));
                make.right.equalTo(self).offset(-15+11);
                make.bottom.equalTo(self.projectIconView).offset(5);
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
    _privateIconView.hidden =(_project.is_public!=nil)? _project.is_public.boolValue:([_project.type intValue]==2)?FALSE:TRUE;
    if (_hidePrivateIcon) {
        _privateIconView.hidden=TRUE;
    }
    
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
    
    [_ownerTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.height.equalTo(self.projectTitleLabel);
        make.left.equalTo(self.privateIconView);
        make.bottom.equalTo(_projectIconView.mas_bottom);
    }];
    
    [_describeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.privateIconView);
        make.height.equalTo(@(38));
        make.width.equalTo(@(kScreen_Width-kLeftOffset-kIconSize-20));
        make.top.equalTo(_projectTitleLabel.mas_bottom);
    }];


    //Title & UserName & description
    if (_openKeywords) {
        _projectTitleLabel.attributedText=[NSString getAttributeFromText:_project.name emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    }else{
        _projectTitleLabel.text = _project.name;
    }
    
    if (_openKeywords) {
        _describeLabel.attributedText=[NSString getAttributeFromText:_project.description_mine emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    }else{
        _describeLabel.text=_project.description_mine;
    }
    _ownerTitleLabel.text = _project.owner_user_name? _project.owner_user_name:[[[[_project.project_path componentsSeparatedByString:@"/p"] firstObject] componentsSeparatedByString:@"u/"] lastObject];

    
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
    _setCommonBtn.hidden=!hasSWButtons;
}

- (NSArray *)rightButtons{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:_project.pin.boolValue? kColorTableSectionBg: kColorBrandGreen
                                                title:_project.pin.boolValue?@"取消常用":@"设置常用"
                                           titleColor:_project.pin.boolValue? kColorBrandGreen: [UIColor whiteColor]];
    return rightUtilityButtons;
}

-(void)showSliderAction
{
    NSLog(@"tap");
    [self showRightUtilityButtonsAnimated:TRUE];
}

@end
