//
//  ProjectCodeListCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//


#define kCode_IconViewWidth 25.0
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
        // Initialization code
        if (!_leftIconView) {
            _leftIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([self.class cellHeight] - kCode_IconViewWidth)/2, kCode_IconViewWidth, kCode_IconViewWidth)];
            [self.contentView addSubview:_leftIconView];
        }
        if (!_fileName) {
            _fileName = [[UILabel alloc] initWithFrame:CGRectMake(kCode_ContentLeftPading, 10, kScreen_Width-kCode_ContentLeftPading-30, 20)];
            _fileName.font = [UIFont systemFontOfSize:15];
            _fileName.textColor = kColor222;
            [self.contentView addSubview:_fileName];
        }
        if (!_commitTime) {
            _commitTime = [[UILabel alloc] initWithFrame:CGRectMake(kCode_ContentLeftPading, [self.class cellHeight]-25, kScreen_Width-kCode_ContentLeftPading-30, 20)];
            _commitTime.font = [UIFont systemFontOfSize:12];
            _commitTime.textColor = kColor999;
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
    self.commitTime.attributedText = [self subTitleStr];
//    self.commitTime.text = [[self subTitleStr] string];
}

- (NSAttributedString *)subTitleStr{
    NSString *nameStr = _file.info.lastCommitter.name? _file.info.lastCommitter.name: @"...";
    NSString *timeStr = _file.info.lastCommitDate? [_file.info.lastCommitDate stringTimesAgo]: @"...";
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", nameStr, timeStr]];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor222}
                        range:NSMakeRange(0, nameStr.length)];
    [attrString addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:12],
                                NSForegroundColorAttributeName : kColor999}
                        range:NSMakeRange(nameStr.length + 1, timeStr.length)];
    return attrString;
}

+ (CGFloat)cellHeight{
    return 60.0;
}

@end

