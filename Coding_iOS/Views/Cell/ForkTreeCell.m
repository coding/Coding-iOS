//
//  ForkTreeCell.m
//  Coding_iOS
//
//  Created by Ease on 15/9/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kForkTreeCell_IconWidth 40.0

#import "ForkTreeCell.h"

@interface ForkTreeCell ()
@property (nonatomic, strong) UIImageView *forkerIconView;
@property (nonatomic, strong) UILabel *projectTitleLabel;
@property (nonatomic, strong) UILabel *forkInfoLabel;

@end

@implementation ForkTreeCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_forkerIconView) {
            _forkerIconView = [UIImageView new];
            _forkerIconView.layer.masksToBounds = YES;
            _forkerIconView.layer.cornerRadius = kForkTreeCell_IconWidth/2;
            [self.contentView addSubview:_forkerIconView];
        }
        
        if (!_projectTitleLabel) {
            _projectTitleLabel = [UILabel new];
            _projectTitleLabel.textColor = kColor222;
            _projectTitleLabel.font = [UIFont systemFontOfSize:15];
            [self.contentView addSubview:_projectTitleLabel];
        }
        if (!_forkInfoLabel) {
            _forkInfoLabel = [UILabel new];
            _forkInfoLabel.textColor = kColor999;
            _forkInfoLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_forkInfoLabel];
        }
        [_forkerIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(kForkTreeCell_IconWidth, kForkTreeCell_IconWidth));
        }];
        [_projectTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.height.mas_equalTo(20);
            make.left.equalTo(self.forkerIconView.mas_right).offset(20);
            make.right.lessThanOrEqualTo(self.contentView).offset(0);
        }];
        [_forkInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.equalTo(self.projectTitleLabel);
            make.top.equalTo(self.projectTitleLabel.mas_bottom).offset(5);
        }];
    }
    return self;
}

- (void)setProject:(Project *)project{
    _project = project;
    if (!_project) {
        return;
    }
    [_forkerIconView sd_setImageWithURL:[_project.owner.avatar urlImageWithCodePathResize:2*kForkTreeCell_IconWidth crop:YES] placeholderImage:kPlaceholderCodingSquareWidth(55.0)];
    _projectTitleLabel.text = _project.path;
    _forkInfoLabel.text = [NSString stringWithFormat:@"%@ Fork于 %@", _project.owner.name, [project.created_at stringDisplay_HHmm]];
}

+ (CGFloat)cellHeight{
    return 60.0;
}
@end
