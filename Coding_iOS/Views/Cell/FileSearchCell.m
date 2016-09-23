//
//  FileSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/20.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kFileListFileCell_IconWidth 45.0
#define kFileListFileCell_LeftPading (kPaddingLeftWidth +kFileListFileCell_IconWidth +17.0)
#define kFileListFileCell_TopPading 10.0


#import "FileSearchCell.h"
#import "YLImageView.h"
#import "NSString+Attribute.h"

@interface FileSearchCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel, *infoLabel, *sizeLabel;
@end


@implementation FileSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, (kFileSearchCellHeight - kFileListFileCell_IconWidth)/2, kFileListFileCell_IconWidth, kFileListFileCell_IconWidth)];
            _iconView.contentMode=UIViewContentModeScaleAspectFill;
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = kColorDDD.CGColor;
            [self.contentView addSubview:_iconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, kFileListFileCell_TopPading-3, (kScreen_Width - kFileListFileCell_LeftPading - 60), 25)];
            _nameLabel.textColor = kColor222;
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLabel];
        }
        if (!_sizeLabel) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, (kFileSearchCellHeight- 15)/2+3, (kScreen_Width - kFileListFileCell_LeftPading - 60), 15)];
            _sizeLabel.textColor = kColor999;
            _sizeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_sizeLabel];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, (kFileSearchCellHeight- 15 - kFileListFileCell_TopPading+1), (kScreen_Width - kFileListFileCell_LeftPading - 60), 15)];
            _infoLabel.textColor = kColor999;
            _infoLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_infoLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_file) {
        return;
    }
    _nameLabel.attributedText=[NSString getAttributeFromText:_file.name emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
    _sizeLabel.text = [NSString sizeDisplayWithByte:_file.size.floatValue];
    _infoLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _file.owner.name, [_file.created_at stringDisplay_HHmm]];
    if (_file.preview && _file.preview.length > 0) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:_file.preview]];
    }else{
        _iconView.image = [UIImage imageWithFileType:_file.fileType];
    }
}
@end
