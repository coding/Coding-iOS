//
//  TopicAnswerCommentMoreCell.m
//  Coding_iOS
//
//  Created by Ease on 2016/9/18.
//  Copyright © 2016年 Coding. All rights reserved.
//

#import "TopicAnswerCommentMoreCell.h"

@interface TopicAnswerCommentMoreCell ()
@property (strong, nonatomic) UILabel *contentLabel;
@end

@implementation TopicAnswerCommentMoreCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_contentLabel) {
            _contentLabel = [UILabel labelWithFont:[UIFont systemFontOfSize:14] textColor:kColorBrandGreen];
            [self.contentView addSubview:_contentLabel];
        }
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth + 40);
            make.top.right.equalTo(self.contentView);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}

- (void)setCommentNum:(NSNumber *)commentNum{
    _commentNum = commentNum;
    self.contentLabel.text = [NSString stringWithFormat:@"查看全部%d条评论", _commentNum.intValue];
}

+(CGFloat)cellHeight{
    return 30;
}

@end
