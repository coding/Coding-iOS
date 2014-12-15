//
//  ProjectTaskListViewCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectTaskListViewCell_LeftPading 90.0
#define kProjectTaskListViewCell_RightPading 10.0
#define kProjectTaskListViewCell_CheckBoxWidth 50.0
#define kProjectTaskListViewCell_UserIconWidth 33.0
#define kProjectTaskListViewCell_UpDownPading 10.0
#define kProjectTaskListViewCell_MaxContentHeight 40.0
#define kProjectTaskListViewCell_ContentWidth (kScreen_Width - kProjectTaskListViewCell_LeftPading - kProjectTaskListViewCell_RightPading)
#define kProjectTaskListViewCell_ContentFont [UIFont systemFontOfSize:15]
#define kProjectTaskListViewCell_TextPading 10.0


#import "ProjectTaskListViewCell.h"
#import "Coding_NetAPIManager.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProjectTaskListViewCell ()
@property (strong, nonatomic) UIImageView *userIconView, *commentIconView, *timeClockIconView;
@property (strong, nonatomic) UITapImageView *checkView;
@property (strong, nonatomic) UILabel *contentLabel, *commentCountLabel;
@property (strong, nonatomic) UILabel *userNameLabel, *timeLabel;
@end

@implementation ProjectTaskListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_checkView) {
            _checkView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 10, kProjectTaskListViewCell_CheckBoxWidth, kProjectTaskListViewCell_CheckBoxWidth)];
            _checkView.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:_checkView];
        }
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 0, kProjectTaskListViewCell_UserIconWidth, kProjectTaskListViewCell_UserIconWidth)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, kProjectTaskListViewCell_UpDownPading, kProjectTaskListViewCell_ContentWidth, 20)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
            _contentLabel.font = kProjectTaskListViewCell_ContentFont;
            _contentLabel.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont boldSystemFontOfSize:10];
            _userNameLabel.textColor = [UIColor colorWithHexString:@"0x666666"];
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, 0, 80, 15)];
            _timeLabel.backgroundColor = [UIColor clearColor];
            _timeLabel.font = [UIFont systemFontOfSize:10];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_timeLabel];
        }
        if (!_timeClockIconView) {
            _timeClockIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, 0, 12, 12)];
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
        
        if (!_commentIconView) {
            _commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width - kProjectTaskListViewCell_RightPading- 15 -20), 0, 12, 12)];
            [_commentIconView setImage:[UIImage imageNamed:@"topic_comment_icon"]];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_commentCountLabel) {
            _commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width - kProjectTaskListViewCell_RightPading- 15), 0, 20, 12)];
            _commentCountLabel.font = [UIFont systemFontOfSize:10];
            _commentCountLabel.minimumScaleFactor = 0.5;
            _commentCountLabel.adjustsFontSizeToFitWidth = YES;
            _commentCountLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_commentCountLabel];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_task) {
        return;
    }
    CGFloat cellHeight = [ProjectTaskListViewCell cellHeightWithObj:_task];
    //    图片
    
    [_checkView setImage:[UIImage imageNamed:(_task.status.integerValue == 2? @"checkbox_checked":[NSString stringWithFormat:@"checkbox_priority%d", _task.priority.intValue])]];
    
    __weak typeof(self) weakSelf = self;
    [_checkView addTapBlock:^(id obj) {
        //用户点击后，直接改变任务状态，在block中处理网络请求
        [weakSelf.checkView setImage:[UIImage imageNamed:(weakSelf.task.status.integerValue != 2? @"checkbox_checked":[NSString stringWithFormat:@"checkbox_priority%d", weakSelf.task.priority.intValue])]];
        weakSelf.checkViewClickedBlock(weakSelf.task);
    }];
    
    [_checkView setY:(cellHeight- kProjectTaskListViewCell_CheckBoxWidth)/2];
    //    头像
    
    [_userIconView sd_setImageWithURL:[_task.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_userIconView setY:(cellHeight- kProjectTaskListViewCell_UserIconWidth)/2];
    
    //    文字
    CGFloat curBottomY = kProjectTaskListViewCell_UpDownPading;
    
    if (_task.status.integerValue == 1) {//未完成
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
    }else{
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        //        [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
        //        [mutableAttributedString addAttribute:kTTTStrikeOutAttributeName value:[NSNumber numberWithBool:YES] range:strikeRange];
    }
    [_contentLabel setLongString:_task.content withFitWidth:kProjectTaskListViewCell_ContentWidth maxHeight:kProjectTaskListViewCell_MaxContentHeight];
    
    curBottomY += [_task.content getHeightWithFont:kProjectTaskListViewCell_ContentFont constrainedToSize:CGSizeMake(kProjectTaskListViewCell_ContentWidth, kProjectTaskListViewCell_MaxContentHeight)];
    curBottomY += kProjectTaskListViewCell_TextPading;

    _userNameLabel.text = _task.creator.name;
    _timeLabel.text = [_task.created_at stringTimesAgo];
    [_userNameLabel setY:curBottomY];
    [_userNameLabel sizeToFit];
    
    CGRect frame = _timeClockIconView.frame;
    frame.origin.y = curBottomY;
    frame.origin.x = CGRectGetMaxX(_userNameLabel.frame) +10;
    _timeClockIconView.frame = frame;
    
    frame.origin.x += 15;
    frame.size = _timeLabel.frame.size;
    _timeLabel.frame = frame;
    [_timeLabel sizeToFit];
    
    frame.origin.x = CGRectGetMaxX(_timeLabel.frame) +10;
    frame.size = _commentIconView.frame.size;
    _commentIconView.frame = frame;
    _commentCountLabel.text = _task.comments.stringValue;
    [_commentCountLabel sizeToFit];
    frame.origin.x = CGRectGetMaxX(_commentIconView.frame) +2;
    frame.size = _commentCountLabel.frame.size;
    _commentCountLabel.frame = frame;
    
    
//    _commentCountLabel.text = _task.comments.stringValue;
//    [_commentIconView setY:curBottomY];
//    [_commentCountLabel setY:curBottomY];
    
}
+ (CGFloat)cellHeightWithObj:(id)obj{
    Task *task = (Task *)obj;
    CGFloat cellHeight = 0;
    cellHeight += kProjectTaskListViewCell_UpDownPading *2;
    cellHeight += [task.content getHeightWithFont:kProjectTaskListViewCell_ContentFont constrainedToSize:CGSizeMake(kProjectTaskListViewCell_ContentWidth, kProjectTaskListViewCell_MaxContentHeight)];
    cellHeight += kProjectTaskListViewCell_TextPading;
    cellHeight += 10;//timeLabel的高度
    return cellHeight;
}

@end
