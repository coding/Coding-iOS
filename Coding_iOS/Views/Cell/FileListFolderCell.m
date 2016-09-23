//
//  FileListFolderCell.m
//  Coding_iOS
//
//  Created by Ease on 14/11/14.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kFileListFolderCell_IconWidth 45.0
#define kFileListFolderCell_LeftPading (kPaddingLeftWidth +kFileListFolderCell_IconWidth +20.0)
#define kFileListFolderCell_TopPading 15.0

#import "FileListFolderCell.h"

@interface FileListFolderCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel, *infoLabel;
@end

@implementation FileListFolderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([FileListFolderCell cellHeight] - kFileListFolderCell_IconWidth)/2, kFileListFolderCell_IconWidth, kFileListFolderCell_IconWidth)];
            [self.contentView addSubview:_iconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFolderCell_LeftPading, kFileListFolderCell_TopPading, (kScreen_Width - kFileListFolderCell_LeftPading - 30), 25)];
            _nameLabel.textColor = kColor222;
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLabel];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFolderCell_LeftPading, ([FileListFolderCell cellHeight]- 20 - kFileListFolderCell_TopPading), (kScreen_Width - kFileListFolderCell_LeftPading - 30), 20)];
            _infoLabel.textColor = kColor999;
            _infoLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_infoLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_folder) {
        return;
    }
    if ([_folder isDefaultFolder]) {
        _iconView.image = [UIImage imageNamed:@"icon_file_folder_default"];
    }else{
        _iconView.image = [UIImage imageNamed:@"icon_file_folder_normal"];
    }
    _nameLabel.text = [NSString stringWithFormat:@"%@（%ld）", _folder.name, (long)(_folder.count.integerValue)];
    _infoLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _folder.owner_name, [_folder.updated_at stringDisplay_HHmm]];
}

+ (CGFloat)cellHeight{
    return 75.0;
}


@end

