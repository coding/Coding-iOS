//
//  ProjectCodeListSearchCell.m
//  Coding_iOS
//
//  Created by Ease on 2017/2/15.
//  Copyright © 2017年 Coding. All rights reserved.
//

#import "ProjectCodeListSearchCell.h"

@interface ProjectCodeListSearchCell ()
@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UILabel *fileNameL;
@end

@implementation ProjectCodeListSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        if (!_leftIconView) {
            _leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_code_file"]];
            [self.contentView addSubview:_leftIconView];
        }
        if (!_fileNameL) {
            _fileNameL = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColor222];
            _fileNameL.lineBreakMode = NSLineBreakByTruncatingMiddle;
            [self.contentView addSubview:_fileNameL];
        }
        [_leftIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
        }];
        [_fileNameL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(_leftIconView.mas_right).offset(10);
            make.right.lessThanOrEqualTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_filePath) {
        return;
    }
    self.fileNameL.attributedText = [self attrPath];
}

- (NSAttributedString *)attrPath{
    NSString *shortPath = _filePath;
    if (_treePath.length > 0 && [shortPath hasPrefix:_treePath]) {
        shortPath = [shortPath substringFromIndex:_treePath.length + 1];// '/xxxx'
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:shortPath];
    [attrString addAttributes:@{NSBackgroundColorAttributeName: [UIColor colorWithHexString:@"0xFFEFBD"]}
                        range:[shortPath rangeOfString:_searchText options:NSCaseInsensitiveSearch]];
    return attrString;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
