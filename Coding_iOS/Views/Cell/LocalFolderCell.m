//
//  LocalFolderCell.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "LocalFolderCell.h"

@interface LocalFolderCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@end

@implementation LocalFolderCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        CGFloat icon_width = 45.0;
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_file_folder_normal"]];
            [self.contentView addSubview:_iconView];
        }
        if (!_nameLabel) {
            _nameLabel = [UILabel new];
            _nameLabel.textColor = kColor222;
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLabel];
        }
        [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.size.mas_equalTo(CGSizeMake(icon_width, icon_width));
            make.centerY.equalTo(self.contentView);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_iconView.mas_right).offset(20);
            make.right.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
            make.height.mas_equalTo(30);
        }];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:kColorBrandRed icon:[UIImage imageNamed:@"icon_file_cell_delete"]];
        [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:[LocalFolderCell cellHeight]];
    }
    return self;
}

- (void)setProjectName:(NSString *)name fileCount:(NSInteger)fileCount{
    _nameLabel.text = [NSString stringWithFormat:@"%@（%ld）", name, (long)fileCount];
}

+ (CGFloat)cellHeight{
    return 75.0;
}
@end
