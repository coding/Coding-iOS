//
//  EATaskBoardListTaskCell.m
//  Coding_iOS
//
//  Created by Easeeeeeeeee on 2018/4/27.
//  Copyright © 2018年 Coding. All rights reserved.
//

#import "EATaskBoardListTaskCell.h"
#import "Coding_NetAPIManager.h"

@interface EATaskBoardListTaskCell ()

@property (strong, nonatomic) UIView *innerContentView;

@property (strong, nonatomic) UIImageView *taskPriorityView;
@property (strong, nonatomic) UITapImageView *checkView;
@property (strong, nonatomic) UILabel *contentLabel, *timeLabel;
@property (strong, nonatomic) UIView *tagsView;

@end

@implementation EATaskBoardListTaskCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
        if (!_innerContentView) {
            _innerContentView = [UIView new];
            _innerContentView.backgroundColor = kColorWhite;
            _innerContentView.cornerRadius = 2.0;
            _innerContentView.masksToBounds = YES;
            [self.contentView addSubview:_innerContentView];
        }
        if (!_checkView) {
            _checkView = [UITapImageView new];
            _checkView.contentMode = UIViewContentModeCenter;
            
            __weak typeof(self) weakSelf = self;
            [_checkView addTapBlock:^(id obj) {
                [weakSelf checkViewClicked];
            }];
            [_innerContentView addSubview:_checkView];
        }
        if (!_taskPriorityView) {
            _taskPriorityView = [UIImageView new];
            _taskPriorityView.contentMode = UIViewContentModeScaleAspectFit;
            [_innerContentView addSubview:_taskPriorityView];
        }
        if (!_contentLabel) {
            _contentLabel = [UILabel new];
            _contentLabel.textColor = kColorDark3;
            _contentLabel.font = [UIFont systemFontOfSize:15];
            [_innerContentView addSubview:_contentLabel];
        }
        if (!_timeLabel) {
            _timeLabel = [UILabel new];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            _timeLabel.textColor = kColorDark7;
            [_innerContentView addSubview:_timeLabel];
        }
        if (!_tagsView) {
            _tagsView = [UIView new];
            _tagsView.clipsToBounds = YES;
            [_innerContentView addSubview:_tagsView];
        }
        [_innerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, kPaddingLeftWidth, 10, kPaddingLeftWidth));
        }];
        [_checkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_innerContentView).offset(10);
            make.centerY.equalTo(_contentLabel);
            make.size.mas_equalTo(CGSizeMake(17, 17));
        }];
        [_taskPriorityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_contentLabel);
            make.left.equalTo(_checkView.mas_right).offset(10);
            make.size.mas_equalTo(CGSizeMake(17, 17));
        }];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_innerContentView).offset(15);
            make.left.equalTo(self.taskPriorityView.mas_right).offset(10);
            make.right.equalTo(_innerContentView).offset(-10);
            make.height.mas_equalTo(20);
        }];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentLabel);
            make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(17);
        }];
        [_tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_contentLabel);
            make.right.bottom.equalTo(_innerContentView);
            make.height.mas_equalTo(3);
        }];
    }
    return self;
}

- (void)setTask:(Task *)task{
    _task = task;
    //Top
    [_checkView setImage:[UIImage imageNamed:_task.status.integerValue == 1? @"checkbox_unchecked" : @"checkbox_checked"]];
    [_taskPriorityView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"taskPriority%@_small", _task.priority.stringValue]]];
    _contentLabel.textColor = _task.status.integerValue == 1? kColorDark3: kColorDarkA;
    _contentLabel.text = [_task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self setDate:_task.deadline_date andDone:(_task.status.integerValue != 1)];
    //Tags
    [_tagsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (NSInteger index = 0; index < _task.labels.count; index++) {
        [self p_addTag:_task.labels[index] withIndex:index];
    }
}

- (void)p_addTag:(ProjectTag *)curTag withIndex:(NSInteger)index{
    UIColor *tagColor = curTag.color.length > 1? [UIColor colorWithHexString:[curTag.color stringByReplacingOccurrencesOfString:@"#" withString:@"0x"]]: kColorBrandBlue;
    UIView *tagV = [UIView new];
    tagV.backgroundColor = tagColor;
    tagV.cornerRadius = 2;
    tagV.masksToBounds = YES;
    [_tagsView addSubview:tagV];
    [tagV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.top.bottom.equalTo(_tagsView);
        make.left.equalTo(_tagsView).offset(index * (30 + 5));
    }];
}

- (void)setDate:(NSDate *)deadline_date andDone:(BOOL)done{
    self.timeLabel.hidden = (deadline_date == nil);

    if (deadline_date) {
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
        self.timeLabel.textColor = [UIColor colorWithHexString:textColorStr];
        self.timeLabel.text = deadlineStr;
    }
}

- (void)checkViewClicked{
    if (!_task.isRequesting) {
        _task.isRequesting = YES;
        //用户点击后，直接改变任务状态
        [self.checkView setImage:[UIImage imageNamed:(self.task.status.integerValue != 2? @"checkbox_checked":@"checkbox_unchecked")]];
        //ChangeTaskStatus后，task对象的status属性会直接在请求结束后被修改
        __weak typeof(self) weakSelf = self;
        [[Coding_NetAPIManager sharedManager] request_ChangeTaskStatus:_task andBlock:^(id data, NSError *error) {
            weakSelf.task.isRequesting = NO;
            if (data) {
                if (weakSelf.taskStatusChangedBlock) {
                    weakSelf.taskStatusChangedBlock(weakSelf.task);
                }
            }else{
                [weakSelf.checkView setImage:[UIImage imageNamed:(weakSelf.task.status.integerValue != 2? @"checkbox_checked":@"checkbox_unchecked")]];
            }
        }];
    }
}

+ (CGFloat)cellHeightWithObj:(Task *)obj{
    CGFloat cellHeight = 60;
    if (obj.deadline_date) {
        cellHeight += 22;
    }
    if (obj.labels.count > 0) {
        cellHeight += 5;
    }
    return cellHeight;
}
@end
