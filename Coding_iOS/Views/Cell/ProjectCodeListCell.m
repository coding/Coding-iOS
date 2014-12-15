//
//  ProjectCodeListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kCode_IconViewWidth 34.0
#define kCode_ContentLeftPading (kPaddingLeftWidth+kCode_IconViewWidth+10)

#import "ProjectCodeListCell.h"

@interface ProjectCodeListCell ()
@property (strong, nonatomic) UIImageView *leftIconView;
@property (strong, nonatomic) UILabel *fileName, *commitTime, *commitInfo, *commitorName;
@end


@implementation ProjectCodeListCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        if (!_leftIconView) {
            _leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([self.class cellHeight] - kCode_IconViewWidth)/2, kCode_IconViewWidth, kCode_IconViewWidth)];
            [self.contentView addSubview:_leftIconView];
        }
        if (!_fileName) {
            _fileName = [[UILabel alloc] initWithFrame:CGRectMake(kCode_ContentLeftPading, 10, kScreen_Width-kCode_ContentLeftPading-30, 20)];
            _fileName.font = [UIFont systemFontOfSize:15];
            _fileName.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_fileName];
        }
        if (!_commitTime) {
            _commitTime = [[UILabel alloc] initWithFrame:CGRectMake(kCode_ContentLeftPading, [self.class cellHeight]-25, kScreen_Width-kCode_ContentLeftPading-30, 20)];
            _commitTime.font = [UIFont systemFontOfSize:12];
            _commitTime.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_commitTime];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_file) {
        return;
    }
    if ([_file.mode isEqualToString:@"tree"]) {
        self.leftIconView.image = [UIImage imageNamed:@"icon_code_tree"];
    }else{
        self.leftIconView.image = [UIImage imageNamed:@"icon_code_file"];
    }
    self.fileName.text = _file.name;
    if (_file.info && _file.info.lastCommitter.name) {
        self.commitTime.text = [NSString stringWithFormat:@"%@    %@",[_file.info.lastCommitDate stringTimesAgo] ,_file.info.lastCommitter.name]; ;
    }else{
        self.commitTime.text = @"...    ...";
    }
}

+ (CGFloat)cellHeight{
    return 60.0;
}

@end

