//
//  ProjectListTaCell.m
//  Coding_iOS
//
//  Created by Ease on 15/3/19.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#define kProjectListTaCell_IconWidth 55

#import "ProjectListTaCell.h"

@interface ProjectListTaCell ()
@property (nonatomic, strong) UIImageView *iconV, *starV, *watchV, *forkV;
@property (strong, nonatomic) UILabel *nameL, *desL, *starL, *watchL, *forkL;
@end

@implementation ProjectListTaCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_iconV) {
            _iconV = [[UIImageView alloc] init];
            _iconV.layer.masksToBounds = YES;
            _iconV.layer.cornerRadius = 2.0;
            [self.contentView addSubview:_iconV];
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
        
        if (!_nameL) {
            _nameL = [[UILabel alloc] init];
            _nameL.textColor = kColor222;
            _nameL.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameL];
        }
        if (!_desL) {
            _desL = [[UILabel alloc] init];
            _desL.textColor = kColor999;
            _desL.font = [UIFont systemFontOfSize:14];
            [self.contentView addSubview:_desL];
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
        
        [_iconV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kProjectListTaCell_IconWidth, kProjectListTaCell_IconWidth));
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
        }];
        [_nameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(20);
            make.left.equalTo(_iconV.mas_right).offset(20);
            make.right.equalTo(self.contentView);
            make.bottom.equalTo(_desL.mas_top).offset(-5);
        }];
        [_desL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(15);
            make.left.right.equalTo(_nameL);
            make.bottom.equalTo(_starV.mas_top).offset(-5);
        }];
        [_starV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_iconV);
            make.left.equalTo(_nameL);
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

- (void)setProject:(Project *)project{
    _project = project;
    if (!_project) {
        return;
    }
    [_iconV sd_setImageWithURL:[_project.icon urlImageWithCodePathResize:2*kProjectListTaCell_IconWidth] placeholderImage:kPlaceholderCodingSquareWidth(55.0) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        DebugLog(@"_project: %@, imageURL: %@", _project.name, imageURL.absoluteString);
    }];
    _nameL.text = _project.name;
    _desL.text = _project.description_mine;
    _starL.text = _project.star_count.stringValue;
    _watchL.text = _project.watch_count.stringValue;
    _forkL.text = _project.fork_count.stringValue;
    
    [_starL sizeToFit];
    [_watchL sizeToFit];
    [_forkL sizeToFit];
}

+ (CGFloat)cellHeight{
    return 75.0;
}
@end
