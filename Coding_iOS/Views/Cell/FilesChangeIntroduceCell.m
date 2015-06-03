//
//  FilesChangeIntroduceCell.m
//  Coding_iOS
//
//  Created by Ease on 15/6/1.
//  Copyright (c) 2015年 Coding. All rights reserved.
//

#import "FilesChangeIntroduceCell.h"

@interface FilesChangeIntroduceCell ()
@property (strong, nonatomic) UILabel *contentL;
@end

@implementation FilesChangeIntroduceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    NSString *filesCountStr = [NSString stringWithFormat:@"%d个文件", filesCount];
    NSString *insertionsStr = [NSString stringWithFormat:@"%d个新增", insertions];
    NSString *deletionsStr = [NSString stringWithFormat:@"%d个删除", deletions];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 共%@和%@", filesCountStr, insertionsStr, deletionsStr]];
    NSDictionary *attrLeft = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                               NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x4E90BF"]};
    NSDictionary *attrRight = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                                NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]};
    NSDictionary *attrCommon = @{NSFontAttributeName : [UIFont systemFontOfSize:15],
                                 NSForegroundColorAttributeName : [UIColor colorWithHexString:@"0x222222"]};
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
