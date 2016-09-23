//
//  TaskCommentTopCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "TaskCommentTopCell.h"

@interface TaskCommentTopCell ()
@property (strong, nonatomic) UIImageView *bottomLineView;
@end

@implementation TaskCommentTopCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_bottomLineView) {
            _bottomLineView = [[UIImageView alloc] initWithFrame:CGRectMake(20, [self.class cellHeight]-6, kScreen_Width-20, 10)];
            _bottomLineView.image = [[UIImage imageNamed:@"comment_count_top_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 38, 0, 2)];
            [self.contentView addSubview:_bottomLineView];
        }
        if (!_commentNumStrLabel) {
            _commentNumStrLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 250, 20)];
            _commentNumStrLabel.font = [UIFont systemFontOfSize:13];
            _commentNumStrLabel.textColor = kColor666;
            [self.contentView addSubview:_commentNumStrLabel];
        }
    }
    return self;
}

+ (CGFloat)cellHeight{
    return 30;
}

@end
