//
//  LocalFileCell.m
//  Coding_iOS
//
//  Created by Ease on 15/9/22.
//  Copyright © 2015年 Coding. All rights reserved.
//

#import "LocalFileCell.h"
#import <NYXImagesKit/NYXImagesKit.h>

@interface LocalFileCell ()
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@end

@implementation LocalFileCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        // Initialization code
        CGFloat icon_width = 45.0;
        if (!_iconView) {
            _iconView = [UIImageView new];
            _iconView.contentMode = UIViewContentModeScaleAspectFill;
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = kColorDDD.CGColor;
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
        [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:[LocalFileCell cellHeight]];
    }
    return self;
}

- (void)setFileUrl:(NSURL *)fileUrl{
    
    NSArray *valueList = [[[fileUrl.path componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"|||"];
    NSString *name = valueList[0];
    _nameLabel.text = name;
    
    NSString *fileType = [[[name componentsSeparatedByString:@"."] lastObject] lowercaseString];
    UIImage *image;
    if ([@[@"jpg",
           @"jpeg",
           @"png",
           @"bmp"] containsObject:fileType]) {
        image = [UIImage imageWithContentsOfFile:fileUrl.path];
    }
    if (image) {
        CGFloat icon_width = 2 * 45.0;
        image = [image scaleToSize:CGSizeMake(icon_width, icon_width) usingMode:NYXResizeModeAspectFill];
    }else{
        image = [UIImage imageWithFileType:fileType];
    }
    _iconView.image = image;
}

+ (CGFloat)cellHeight{
    return 75.0;
}
@end
