//
//  ProjectTaskListViewCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectTaskListViewCell_LeftPading 93.0
#define kProjectTaskListViewCell_RightPading 10.0
#define kProjectTaskListViewCell_CheckBoxWidth 41.0
#define kProjectTaskListViewCell_UserIconWidth 33.0
#define kProjectTaskListViewCell_UpDownPading 10.0
#define kProjectTaskListViewCell_MaxContentHeight 40.0
#define kProjectTaskListViewCell_ContentWidth (kScreen_Width - kProjectTaskListViewCell_LeftPading - kProjectTaskListViewCell_RightPading)
#define kProjectTaskListViewCell_ContentFont [UIFont systemFontOfSize:15]
#define kProjectTaskListViewCell_TextPading 10.0


#import "ProjectTaskListViewCell.h"
#import "Coding_NetAPIManager.h"

@interface ProjectTaskListViewCell ()
@property (strong, nonatomic) UIImageView *userIconView, *commentIconView, *timeClockIconView, *taskPriorityView;
@property (strong, nonatomic) UITapImageView *checkView;
@property (strong, nonatomic) UILabel *contentLabel, *deadlineLabel, *userNameLabel, *timeLabel, *commentCountLabel;
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
            _checkView = [[UITapImageView alloc] initWithFrame:CGRectMake(5, 10, kProjectTaskListViewCell_CheckBoxWidth, kProjectTaskListViewCell_CheckBoxWidth)];
            _checkView.contentMode = UIViewContentModeCenter;
            [self.contentView addSubview:_checkView];
        }
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 0, kProjectTaskListViewCell_UserIconWidth, kProjectTaskListViewCell_UserIconWidth)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_taskPriorityView) {
            _taskPriorityView = [[UIImageView alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, kProjectTaskListViewCell_UpDownPading, 17, 17)];
            _taskPriorityView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_taskPriorityView];
        }
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, kProjectTaskListViewCell_UpDownPading, kProjectTaskListViewCell_ContentWidth, 20)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
            _contentLabel.font = kProjectTaskListViewCell_ContentFont;
            _contentLabel.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_contentLabel];
        }
        if (!_deadlineLabel) {
            _deadlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, 0, 60, 15)];
            _deadlineLabel.layer.masksToBounds = YES;
            _deadlineLabel.layer.cornerRadius = 2.0;
            
            _deadlineLabel.backgroundColor = [UIColor clearColor];
            _deadlineLabel.font = [UIFont boldSystemFontOfSize:10];
            _deadlineLabel.textColor = [UIColor whiteColor];
            [self.contentView addSubview:_deadlineLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kProjectTaskListViewCell_LeftPading, 0, 150, 15)];
            _userNameLabel.backgroundColor = [UIColor clearColor];
            _userNameLabel.font = [UIFont systemFontOfSize:10];
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
    [_checkView setImage:[UIImage imageNamed:(_task.status.integerValue == 2? @"checkbox_checked":@"checkbox_priority")]];

    
    __weak typeof(self) weakSelf = self;
    [_checkView addTapBlock:^(id obj) {
        //用户点击后，直接改变任务状态，在block中处理网络请求
        [weakSelf.checkView setImage:[UIImage imageNamed:(weakSelf.task.status.integerValue != 2? @"checkbox_checked":@"checkbox_priority")]];
        weakSelf.checkViewClickedBlock(weakSelf.task);
    }];
    
    [_checkView setY:(cellHeight- kProjectTaskListViewCell_CheckBoxWidth)/2];
    //    头像
    
    [_userIconView sd_setImageWithURL:[_task.owner.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderMonkeyRoundView(_userIconView)];
    [_userIconView setY:(cellHeight- kProjectTaskListViewCell_UserIconWidth)/2];
    
    //优先级
    [_taskPriorityView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"taskPriority%@_small", _task.priority.stringValue]]];
    
    //    文字
    CGFloat curBottomY = kProjectTaskListViewCell_UpDownPading;
    
    if (_task.status.integerValue == 1) {//未完成
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        if (_task.deadline_date) {
            NSInteger leftDayCount = [_task.deadline_date leftDayCount];
            UIColor *deadlineBGColor;
            NSString *deadlineStr;
            switch (leftDayCount) {
                case 0:
                    deadlineBGColor = [UIColor colorWithHexString:@"0xefa230"];
                    deadlineStr = @" 今天 ";
                    break;
                case 1:
                    deadlineBGColor = [UIColor colorWithHexString:@"0x95b763"];
                    deadlineStr = @" 明天 ";
                    break;
                default:
                    deadlineBGColor = leftDayCount > 0? [UIColor colorWithHexString:@"0xb2c6d0"]: [UIColor colorWithHexString:@"0xf24b4b"];
                    deadlineStr = [_task.deadline_date stringWithFormat:@" MM/dd "];
                    break;
            }
            _deadlineLabel.backgroundColor = deadlineBGColor;
            _deadlineLabel.text = deadlineStr;
        }
    }else{
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _deadlineLabel.backgroundColor = [UIColor colorWithHexString:@"0xc8c8c8"];
    }
    NSString *contentStr = [NSString stringWithFormat:@"     %@", [_task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [_contentLabel setLongString:contentStr withFitWidth:kProjectTaskListViewCell_ContentWidth maxHeight:kProjectTaskListViewCell_MaxContentHeight];
    
    curBottomY += [contentStr getHeightWithFont:kProjectTaskListViewCell_ContentFont constrainedToSize:CGSizeMake(kProjectTaskListViewCell_ContentWidth, kProjectTaskListViewCell_MaxContentHeight)];
    curBottomY += kProjectTaskListViewCell_TextPading;
    
    
    CGFloat curRightX = kProjectTaskListViewCell_LeftPading;
    if (_task.deadline_date) {
        _deadlineLabel.hidden = NO;
        [_deadlineLabel setOrigin:CGPointMake(curRightX, curBottomY)];
        [_deadlineLabel sizeToFit];
        curRightX = _deadlineLabel.maxXOfFrame +10;
    }else{
        _deadlineLabel.hidden = YES;
    }

    [_userNameLabel setOrigin:CGPointMake(curRightX, curBottomY)];
    _userNameLabel.text = _task.creator.name;
    [_userNameLabel sizeToFit];
    
    curRightX = _userNameLabel.maxXOfFrame +10;
    [_timeClockIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_timeLabel setOrigin:CGPointMake(curRightX +15, curBottomY)];
    _timeLabel.text = [_task.created_at stringTimesAgo];
    [_timeLabel sizeToFit];
    
    curRightX = _timeLabel.maxXOfFrame +10;
    [_commentIconView setOrigin:CGPointMake(curRightX, curBottomY)];
    [_commentCountLabel setOrigin:CGPointMake(curRightX +15, curBottomY)];
    _commentCountLabel.text = _task.comments.stringValue;
    [_commentCountLabel sizeToFit];
}
+ (CGFloat)cellHeightWithObj:(id)obj{
    Task *task = (Task *)obj;
    CGFloat cellHeight = 0;
    cellHeight += kProjectTaskListViewCell_UpDownPading *2;
    NSString *contentStr = [NSString stringWithFormat:@"     %@", [task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    cellHeight += [contentStr getHeightWithFont:kProjectTaskListViewCell_ContentFont constrainedToSize:CGSizeMake(kProjectTaskListViewCell_ContentWidth, kProjectTaskListViewCell_MaxContentHeight)];
    cellHeight += kProjectTaskListViewCell_TextPading;
    cellHeight += 10;//timeLabel的高度
    return cellHeight;
}

@end
