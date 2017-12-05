//
//  LeftImage_LRTextCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import "LeftImage_LRTextCell.h"
#import "Task.h"

@interface LeftImage_LRTextCell ()
@property (strong, nonatomic) id aObj;
@property (assign, nonatomic) LeftImage_LRTextCellType type;

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *leftLabel, *rightLabel;
@end

@implementation LeftImage_LRTextCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([LeftImage_LRTextCell cellHeight] - 33) / 2, 33, 33)];
            [self.contentView addSubview:_iconView];
        }
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,  ([LeftImage_LRTextCell cellHeight] - 30) / 2, 80, 30)];
            _leftLabel.font = [UIFont systemFontOfSize:15];
            _leftLabel.textColor = kColorDark3;
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_leftLabel];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftLabel.frame),  ([LeftImage_LRTextCell cellHeight] - 30) / 2, kScreen_Width - CGRectGetMaxX(_leftLabel.frame) - 35, 30)];
            _rightLabel.font = [UIFont systemFontOfSize:15];
            _rightLabel.textColor = kColorDark7;
            _rightLabel.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:_rightLabel];
        }
    }
    return self;
}

- (void)setObj:(id)aObj type:(LeftImage_LRTextCellType)type{
    _aObj = aObj;
    _type = type;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.userInteractionEnabled = YES;

    if ([_aObj isKindOfClass:[Task class]]) {
        Task *task = (Task *)_aObj;
        switch (_type) {
            case LeftImage_LRTextCellTypeTaskProject:
            {
                [_iconView doCircleFrame];
                [_iconView sd_setImageWithURL:[task.project.icon urlImageWithCodePathResizeToView:_iconView] placeholderImage:[UIImage imageNamed:@"taskProject"]];
                _leftLabel.text = @"所属项目";
                if (task.project) {
                    _rightLabel.text = [NSString stringWithFormat:@"%@/%@", task.project.owner_user_name, task.project.name];
                }else{
                    _rightLabel.text = @"未指定";
                }
                self.userInteractionEnabled = (task.handleType == TaskHandleTypeAddWithoutProject);
            }
                break;
            case LeftImage_LRTextCellTypeTaskOwner:
            {
                [_iconView doCircleFrame];
                [_iconView sd_setImageWithURL:[task.owner.avatar urlImageWithCodePathResizeToView:_iconView] placeholderImage:[UIImage imageNamed:@"taskOwner"]];
                _leftLabel.text = @"执行者";
                if (task.owner) {
                    _rightLabel.text = task.owner.name;
                }else{
                    _rightLabel.text = @"未指定";
                }
            }
                break;
            case LeftImage_LRTextCellTypeTaskPriority:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskPriority"]];
                _leftLabel.text = @"优先级";
                if (task.priority && task.priority.intValue < kTaskPrioritiesDisplay.count) {
                    _rightLabel.text = kTaskPrioritiesDisplay[task.priority.intValue];
                }else{
                    _rightLabel.text = @"未指定";
                }
            }
                break;
            case LeftImage_LRTextCellTypeTaskDeadline:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskDeadline"]];
                _leftLabel.text = @"截止日期";
                if (task.deadline_date) {
                    _rightLabel.text = [NSDate stringFromDate:task.deadline_date withFormat:@"MM月dd日"];
                }else{
                    _rightLabel.text = @"未指定";
                }
            }
                break;
            case LeftImage_LRTextCellTypeTaskWatchers:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskWatchers"]];
                _leftLabel.text = @"关注者";
                _rightLabel.text = task.watchers.count > 0? [NSString stringWithFormat:@"%lu 人关注", (unsigned long)task.watchers.count]: @"未添加";
            }
                break;
            case LeftImage_LRTextCellTypeTaskStatus:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskProgress"]];
                _leftLabel.text = @"阶段";
                if (task.status) {
                    _rightLabel.text = task.status.intValue == 1? @"未完成":@"已完成";
                }else{
                    _rightLabel.text = @"未指定";
                }
                self.userInteractionEnabled = (task.handleType == TaskHandleTypeEdit);
            }
                break;
            case LeftImage_LRTextCellTypeTaskResourceReference:
            {
                [_iconView doNotCircleFrame];
                [_iconView setImage:[UIImage imageNamed:@"taskResourceReference"]];
                _leftLabel.text = @"关联资源";
                _rightLabel.text = [NSString stringWithFormat:@"%lu 个资源", (unsigned long)task.resourceReference.itemList.count];
            }
                break;
            default:
                break;
        }
        if ((_type == LeftImage_LRTextCellTypeTaskProject && task.project.icon.length > 0) ||
            (_type == LeftImage_LRTextCellTypeTaskOwner && task.owner.avatar.length > 0)) {
            _iconView.contentMode = UIViewContentModeScaleAspectFill;
        }else{
            _iconView.contentMode = UIViewContentModeCenter;
        }
    }
}


+ (CGFloat)cellHeight{
    return 50;
}
@end
