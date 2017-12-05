//
//  ProjectTaskListViewCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-16.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kProjectTaskListViewCell_LeftPading 93.0
#define kProjectTaskListViewCell_RightPading 10.0
#define kProjectTaskListViewCell_CheckBoxWidth 17.0
#define kProjectTaskListViewCell_UserIconWidth 33.0
#define kProjectTaskListViewCell_UpDownPading 10.0
#define kProjectTaskListViewCell_MaxContentHeight 20.0
#define kProjectTaskListViewCell_ContentWidth (kScreen_Width - kProjectTaskListViewCell_LeftPading - kProjectTaskListViewCell_RightPading)
#define kProjectTaskListViewCell_ContentFont [UIFont systemFontOfSize:15]
#define kProjectTaskListViewCell_TextPading 10.0


#define kProjectTaskListViewCellTagsView_Font [UIFont systemFontOfSize:12]


#import "ProjectTaskListViewCell.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTagLabel.h"

@interface ProjectTaskListViewCell ()
@property (strong, nonatomic) UIImageView *userIconView, *commentIconView, *timeClockIconView, *mdIconView, *taskPriorityView;
@property (strong, nonatomic) UITapImageView *checkView;
@property (strong, nonatomic) UILabel *contentLabel, *userNameLabel, *timeLabel, *commentCountLabel, *mdLabel, *numLabel;
@property (strong, nonatomic) ProjectTaskListViewCellTagsView *tagsView;
@end

@implementation ProjectTaskListViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_checkView) {
            _checkView = [UITapImageView new];
            _checkView.contentMode = UIViewContentModeCenter;
            
            __weak typeof(self) weakSelf = self;
            [_checkView addTapBlock:^(id obj) {
                //用户点击后，直接改变任务状态，在block中处理网络请求
                [weakSelf.checkView setImage:[UIImage imageNamed:(weakSelf.task.status.integerValue != 2? @"checkbox_checked":@"checkbox_unchecked")]];
                if (weakSelf.checkViewClickedBlock) {
                    weakSelf.checkViewClickedBlock(weakSelf.task);
                }
            }];
            [self.contentView addSubview:_checkView];
        }
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kProjectTaskListViewCell_UserIconWidth, kProjectTaskListViewCell_UserIconWidth)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
        if (!_taskPriorityView) {
            _taskPriorityView = [UIImageView new];
            _taskPriorityView.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_taskPriorityView];
        }
        if (!_contentLabel) {
            _contentLabel = [UILabel new];
            _contentLabel.textColor = kColorDark3;
            _contentLabel.font = kProjectTaskListViewCell_ContentFont;
            [self.contentView addSubview:_contentLabel];
        }
        if (!_tagsView) {
            _tagsView = [ProjectTaskListViewCellTagsView new];
            [self.contentView addSubview:_tagsView];
        }
        if (!_numLabel) {
            _numLabel = [UILabel new];
            _numLabel.font = [UIFont systemFontOfSize:10];
            _numLabel.textColor = kColorDark7;
            [self.contentView addSubview:_numLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [UILabel new];
            _userNameLabel.font = [UIFont systemFontOfSize:10];
            _userNameLabel.textColor = kColorDark7;
            [self.contentView addSubview:_userNameLabel];
        }
        if (!_timeClockIconView) {
            _timeClockIconView = [UIImageView new];
            _timeClockIconView.image = [UIImage imageNamed:@"time_clock_icon"];
            [self.contentView addSubview:_timeClockIconView];
        }
        if (!_timeLabel) {
            _timeLabel = [UILabel new];
            _timeLabel.font = [UIFont systemFontOfSize:10];
            _timeLabel.textColor = kColorDark7;
            [self.contentView addSubview:_timeLabel];
        }
        if (!_commentIconView) {
            _commentIconView = [UIImageView new];
            [_commentIconView setImage:[UIImage imageNamed:@"topic_comment_icon"]];
            [self.contentView addSubview:_commentIconView];
        }
        if (!_commentCountLabel) {
            _commentCountLabel = [UILabel new];
            _commentCountLabel.font = [UIFont systemFontOfSize:10];
            _commentCountLabel.textColor = kColorDark7;
            [self.contentView addSubview:_commentCountLabel];
        }
        if (!_mdIconView) {
            _mdIconView = [UIImageView new];
            [_mdIconView setImage:[UIImage imageNamed:@"task_description_icon"]];
            [self.contentView addSubview:_mdIconView];
        }
        if (!_mdLabel) {
            _mdLabel = [UILabel new];
            _mdLabel.font = [UIFont systemFontOfSize:10];
            _mdLabel.textColor = kColorDark7;
            _mdLabel.text = @"描述";
            [self.contentView addSubview:_mdLabel];
        }
        
        [_checkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(kProjectTaskListViewCell_CheckBoxWidth,
                                             kProjectTaskListViewCell_CheckBoxWidth));
        }];
        [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.checkView.mas_right).offset(15);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(kProjectTaskListViewCell_UserIconWidth,
                                             kProjectTaskListViewCell_UserIconWidth));
        }];
        [_taskPriorityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(15);
            make.left.equalTo(self.userIconView.mas_right).offset(10);
            make.size.mas_equalTo(CGSizeMake(17, 17));
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.taskPriorityView);
            make.left.equalTo(self.taskPriorityView.mas_right).offset(10);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        [_tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentLabel.mas_bottom).offset(10);
            make.left.equalTo(self.userIconView.mas_right).offset(10);
            make.height.mas_equalTo(25);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        }];
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-15);
            make.left.equalTo(self.userIconView.mas_right).offset(10);
            make.height.mas_equalTo(15);
        }];
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.numLabel.mas_right).offset(10);
            make.centerY.equalTo(self.numLabel);
            make.height.mas_equalTo(15);
        }];
        [_timeClockIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.userNameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.userNameLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeClockIconView.mas_right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
            make.height.mas_equalTo(15);
        }];
        [_commentIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeLabel.mas_right).offset(10);
            make.centerY.equalTo(self.userNameLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_commentCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commentIconView.mas_right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
            make.height.mas_equalTo(15);
        }];
        [_mdIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.commentCountLabel.mas_right).offset(10);
            make.centerY.equalTo(self.userNameLabel);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        [_mdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mdIconView.mas_right).offset(5);
            make.centerY.equalTo(self.userNameLabel);
            make.height.mas_equalTo(15);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_task) {
        return;
    }
    //Top
    [_checkView setImage:[UIImage imageNamed:_task.status.integerValue == 1? @"checkbox_unchecked" : @"checkbox_checked"]];
    [_userIconView sd_setImageWithURL:[_task.owner.avatar urlImageWithCodePathResize:2*kProjectTaskListViewCell_UserIconWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(kProjectTaskListViewCell_UserIconWidth)];
    [_taskPriorityView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"taskPriority%@_small", _task.priority.stringValue]]];
    _contentLabel.textColor = _task.status.integerValue == 1? kColorDark3: kColorDarkA;
//    [UIColor colorWithHexString:_task.status.integerValue == 1? @"0x222222" : @"0x999999"];
    _contentLabel.text = [_task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //Tags
    if (_task.deadline_date || _task.labels.count > 0) {
        _tagsView.tags = _task.labels;
        _tagsView.deadline_date = _task.deadline_date;
        _tagsView.done = (_task.status.integerValue != 1);
        [_tagsView reloadData];
        _tagsView.hidden = NO;
    }else{
        _tagsView.hidden = YES;
    }
    //Bottom
    _numLabel.text = [NSString stringWithFormat:@"#%@", _task.number.stringValue];
    _userNameLabel.text = _task.creator.name;
    _timeLabel.text = [_task.created_at stringDisplay_MMdd];
    _commentCountLabel.text = _task.comments.stringValue;
    _mdIconView.hidden = _mdLabel.hidden = !_task.has_description.boolValue;
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Task class]]) {
        Task *task = (Task *)obj;
        if (task.deadline_date || task.labels.count > 0) {
            cellHeight = 105;
        }else{
            cellHeight = 70;
        }
    }
    return cellHeight;
}
@end


@interface ProjectTaskListViewCellTagsView ()
@property (strong, nonatomic) NSMutableArray *tagLabelList;
@property (strong, nonatomic) ProjectTaskListViewCellDateView *dateView;
@end

@implementation ProjectTaskListViewCellTagsView
+ (instancetype)viewWithTags:(NSArray *)tags andDate:(NSDate *)deadline_date{
    ProjectTaskListViewCellTagsView *view = [self new];
    view.tags = tags;
    view.deadline_date = deadline_date;
    [view reloadData];
    return view;
}

- (void)reloadData{
    if (_deadline_date) {
        if (!_dateView) {
            _dateView = [ProjectTaskListViewCellDateView viewWithDate:_deadline_date andDone:_done];
            [self addSubview:_dateView];
        }else{
            [_dateView setDate:_deadline_date andDone:_done];
        }
        _dateView.hidden = NO;
    }else{
        _dateView.hidden = YES;
    }
    [_tagLabelList makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat viewWidth = kScreen_Width - 2*kPaddingLeftWidth - 2*10 - kProjectTaskListViewCell_CheckBoxWidth - kProjectTaskListViewCell_UserIconWidth;
    CGFloat curRightX = (!_dateView || _dateView.hidden)? 0: CGRectGetMaxX(_dateView.frame) + 5;
    for (int index = 0; index < _tags.count; index++) {
        ProjectTagLabel *label = [self p_getLabelWithIndex:index];
        [label setX:curRightX];
        [self addSubview:label];
        curRightX += CGRectGetWidth(label.frame);
        if (curRightX > viewWidth
            || (viewWidth - curRightX < 25 && index < _tags.count - 1)) {
            [self p_makeMoreStyleWithTagLabel:label];
            break;
        }
        curRightX += 5;
    }
}

- (ProjectTagLabel *)p_getLabelWithIndex:(NSInteger)index{
    if (index >= _tags.count) {
        return nil;
    }
    ProjectTagLabel *label;
    if (!_tagLabelList) {
        _tagLabelList = [NSMutableArray new];
    }
    if (index < _tagLabelList.count) {
        label = _tagLabelList[index];
        label.curTag = _tags[index];
    }else{
        label = [ProjectTagLabel labelWithTag:_tags[index] font:kProjectTaskListViewCellTagsView_Font height:20 widthPadding:10];
        [_tagLabelList addObject:label];
    }
    return label;
}

- (void)p_makeMoreStyleWithTagLabel:(ProjectTagLabel *)tagLabel{
    tagLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
    tagLabel.textColor = kColorDarkA;
    tagLabel.text = @"···";
    [tagLabel setWidth:15];
}
@end


@interface ProjectTaskListViewCellDateView ()
@property (strong, nonatomic) UIImageView *dateIcon;
@property (strong, nonatomic) UILabel *dateStrL;
@end

@implementation ProjectTaskListViewCellDateView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self doBorderWidth:0.5 color:[UIColor clearColor] cornerRadius:2.0];
        {
            _dateIcon = [UIImageView new];
            [self addSubview:_dateIcon];
        }
        {
            _dateStrL = [UILabel new];
            _dateStrL.font = kProjectTaskListViewCellTagsView_Font;
            [self addSubview:_dateStrL];
        }
        {
            [_dateIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self).offset(5);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
            [_dateStrL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.left.equalTo(self.dateIcon.mas_right).offset(5);
            }];
        }
    }
    return self;
}
+ (instancetype)viewWithDate:(NSDate *)deadline_date andDone:(BOOL)done{
    ProjectTaskListViewCellDateView *view = [self new];
    [view setDate:deadline_date andDone:done];
    return view;
}
- (void)setDate:(NSDate *)deadline_date andDone:(BOOL)done{
    if (!deadline_date) {
        [self setSize:CGSizeZero];
        return;
    }
    NSString *textColorStr, *deadlineStr;
    NSInteger leftDayCount = [deadline_date leftDayCount];
    switch (leftDayCount) {
        case 0:
            textColorStr = @"0xF68435";
            deadlineStr = @"今天";
            break;
        case 1:
            textColorStr = @"0xA1CF64";
            deadlineStr = @"明天";
            break;
        default:
            textColorStr = leftDayCount > 0? @"0x59A2FF": @"0xF56061";
            deadlineStr = [deadline_date stringWithFormat:@"MM/dd"];
            break;
    }
    if (done) {
        textColorStr = @"0xA9B3BE";
    }

    UIColor *textColor = [UIColor colorWithHexString:textColorStr];
    self.layer.borderColor = textColor.CGColor;
    _dateIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"calendar_%@", textColorStr]];
    _dateStrL.textColor = textColor;
    _dateStrL.text = deadlineStr;
    
    CGFloat textWidth = [deadlineStr getWidthWithFont:kProjectTaskListViewCellTagsView_Font constrainedToSize:CGSizeMake(CGFLOAT_MAX, 15)];
    CGSize viewSize = CGSizeMake(textWidth + 12 + 5 * 3, 20);
    [self setSize:viewSize];
}

@end

