//
//  TweetCommentMoreCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-18.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweet_CommentFont [UIFont systemFontOfSize:14]

#import "TweetCommentMoreCell.h"

@interface TweetCommentMoreCell ()
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIImageView *commentIconView, *splitLineView;
@end

@implementation TweetCommentMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
            _commentIconView.image = [UIImage imageNamed:@"tweet_more_comment_icon"];
            _commentIconView.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:_commentIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_commentIconView.maxXOfFrame + 5, 10, 200, 20)];
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.font = kTweet_CommentFont;
            _contentLabel.textColor = kColorDark4;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_splitLineView) {
            _splitLineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 250, 1)];
            _splitLineView.image = [UIImage imageNamed:@"splitlineImg"];
            [self.contentView addSubview:_splitLineView];
            [_splitLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(10);
                make.top.right.equalTo(self.contentView);
                make.height.mas_equalTo(1.0);
            }];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.contentLabel.text = [NSString stringWithFormat:@"查看全部%d条评论", _commentNum.intValue];
}
+(CGFloat)cellHeight{
    return 20 + 10*2;
}
@end
