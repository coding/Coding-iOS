//
//  FileChangesIntroduceCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FileChangesIntroduceCell.h"

@interface FileChangesIntroduceCell ()
@property (strong, nonatomic) UILabel *contentL;
@end

@implementation FileChangesIntroduceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        if (!_contentL) {
            _contentL = [UILabel new];
            [self.contentView addSubview:_contentL];
            [_contentL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(10, kPaddingLeftWidth, 10, kPaddingLeftWidth));
            }];
        }
    }
    return self;
}

- (void)setFilesCount:(NSInteger)filesCount insertions:(NSInteger)insertions deletions:(NSInteger)deletions{
    _contentL.attributedText = [self p_styleStrFromFilesCount:filesCount insertions:insertions deletions:deletions];
}

- (NSAttributedString *)p_styleStrFromFilesCount:(NSInteger)filesCount insertions:(NSInteger)insertions deletions:(NSInteger)deletions{
    NSString *filesCountStr = [NSString stringWithFormat:@"%ld个文件", (long)filesCount];
    NSString *insertionsStr = [NSString stringWithFormat:@"%ld个新增", (long)insertions];
    NSString *deletionsStr = [NSString stringWithFormat:@"%ld个删除", (long)deletions];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 共%@和%@", filesCountStr, insertionsStr, deletionsStr]];
    NSDictionary *attrLeft = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                               NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]};
    NSDictionary *attrRight = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                                NSForegroundColorAttributeName : kColor222};
    NSDictionary *attrCommon = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName : kColor222};
    [attrString addAttributes:attrLeft range:NSMakeRange(0, filesCountStr.length)];
    [attrString addAttributes:attrRight range:NSMakeRange(filesCountStr.length + 2, insertionsStr.length)];
    [attrString addAttributes:attrRight range:NSMakeRange(filesCountStr.length + insertionsStr.length + 3, deletionsStr.length)];
    [attrString addAttributes:attrCommon range:NSMakeRange(filesCountStr.length, 2)];
    [attrString addAttributes:attrCommon range:NSMakeRange(filesCountStr.length + insertionsStr.length + 2, 1)];
    return attrString;
}

+ (CGFloat)cellHeight{
    return 44.0;
}
@end
