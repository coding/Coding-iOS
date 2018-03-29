//
//  EALocalCodeListCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/3/28.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EALocalCodeListCell.h"

@interface EALocalCodeListCell ()

@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UILabel *fileNameL;

@end

@implementation EALocalCodeListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    NSDictionary *attributes = [_curURL resourceValuesForKeys:@[NSURLIsDirectoryKey, NSURLTypeIdentifierKey] error:nil];
    BOOL isDir = [attributes[NSURLIsDirectoryKey] boolValue];
    NSString *itemUTI = attributes[NSURLTypeIdentifierKey] ?: @"unknown";
    _leftIconView.image = [UIImage imageNamed:isDir? @"icon_code_tree": [[NSURL ea_imageUTIList] containsObject:itemUTI]? @"icon_code_image": @"icon_code_file"];
    self.fileNameL.attributedText = [self attrPath];
}

- (NSAttributedString *)attrPath{
    NSString *shortPath = _curURL.lastPathComponent;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:shortPath];
    [attrString addAttributes:@{NSBackgroundColorAttributeName: [UIColor colorWithHexString:@"0xFFEFBD"]}
                        range:[shortPath rangeOfString:_searchText options:NSCaseInsensitiveSearch]];
    return attrString;
}

@end
