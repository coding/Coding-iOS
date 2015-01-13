//
//  TaskCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/28.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTaskCommentCell_FontContent [UIFont systemFontOfSize:15]
#define kTaskCommentCell_LeftPading 20.0

#import "TaskCommentCell.h"

@interface TaskCommentCell ()
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *contentLabel, *timeLabel;
@end

@implementation TaskCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGFloat curBottomY = 10;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftPading, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        CGFloat curWidth = kScreen_Width - 40 - 2*kTaskCommentCell_LeftPading;
        if (!_contentLabel) {
            _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftPading + 40, curBottomY, curWidth, 30)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x555555"];
            _contentLabel.font = kTaskCommentCell_FontContent;
            [self.contentView addSubview:_contentLabel];
        }
        CGFloat commentBtnWidth = 40;
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskCommentCell_LeftPading +40, 0, curWidth- commentBtnWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_curComment) {
        return;
    }
    CGFloat curBottomY = 10;
    CGFloat curWidth = kScreen_Width - 40 - 2*kTaskCommentCell_LeftPading;
    [_ownerIconView sd_setImageWithURL:[_curComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    NSString *contentStr = _curComment.content;
    NSInteger imageCount = _curComment.htmlMedia.imageItems.count;
    for (int i = 0; i < imageCount; i++) {
        contentStr = [contentStr stringByAppendingString:@" [图片] "];
    }
    [_contentLabel setLongString:contentStr withFitWidth:curWidth];
    curBottomY += [contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5;
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _curComment.owner.name, [_curComment.created_at stringTimesAgo]];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[TaskComment class]]) {
        TaskComment *curComment = (TaskComment *)obj;
        CGFloat curWidth = kScreen_Width - 40 - 2*kTaskCommentCell_LeftPading;
        NSString *contentStr = curComment.content;
        NSInteger imageCount = curComment.htmlMedia.imageItems.count;
        for (int i = 0; i < imageCount; i++) {
            contentStr = [contentStr stringByAppendingString:@" [图片] "];
        }
        cellHeight += 10 +[contentStr getHeightWithFont:kTaskCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5 +20 +10;
    }
    return cellHeight;
}


@end
