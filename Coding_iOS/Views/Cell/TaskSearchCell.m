//
//  TaskSearchCell.m
//  Coding_iOS
//
//  Created by jwill on 15/11/23.
//  Copyright © 2015年 Coding. All rights reserved.
//

#define kBaseCellHeight 86
#define kDetialContentMaxHeight 36


#define kProjectTaskListViewCell_LeftPading 93.0
#define kProjectTaskListViewCell_RightPading 10.0
#define kProjectTaskListViewCell_UserIconWidth 40.0
#define kProjectTaskListViewCell_UpDownPading 10.0
#define kProjectTaskListViewCell_MaxContentHeight 20.0
#define kProjectTaskListViewCell_ContentWidth (kScreen_Width - kProjectTaskListViewCell_LeftPading - kProjectTaskListViewCell_RightPading)
#define kProjectTaskListViewCell_ContentFont [UIFont systemFontOfSize:15]
#define kInnerHorizonOffset 12.0


#import "TaskSearchCell.h"
#import "Coding_NetAPIManager.h"
#import "ProjectTagLabel.h"
#import "NSString+Attribute.h"

@interface TaskSearchCell ()
@property (strong, nonatomic) UIImageView *userIconView, *commentIconView, *timeClockIconView, *mdIconView;
@property (strong, nonatomic) UILabel *contentLabel, *userNameLabel, *timeLabel, *commentCountLabel, *mdLabel, *numLabel,*describeLabel;
@end


@implementation TaskSearchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kProjectTaskListViewCell_UserIconWidth, kProjectTaskListViewCell_UserIconWidth)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }

        if (!_contentLabel) {
            _contentLabel = [UILabel new];
            _contentLabel.textColor = kColor222;
            _contentLabel.font = kProjectTaskListViewCell_ContentFont;
            [self.contentView addSubview:_contentLabel];
        }
        
        if (!_describeLabel) {
            _describeLabel = [UILabel new];
            _describeLabel.textColor = kColor666;
            _describeLabel.font = kProjectTaskListViewCell_ContentFont;
            _describeLabel.numberOfLines=2;
            [self.contentView addSubview:_describeLabel];
        }

        if (!_numLabel) {
            _numLabel = [UILabel new];
            _numLabel.font = [UIFont systemFontOfSize:10];
            _numLabel.textColor = kColor222;
            [self.contentView addSubview:_numLabel];
        }
        if (!_userNameLabel) {
            _userNameLabel = [UILabel new];
            _userNameLabel.font = [UIFont systemFontOfSize:10];
            _userNameLabel.textColor = kColor666;
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
            _timeLabel.textColor = kColor999;
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
            _commentCountLabel.textColor = kColor999;
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
            _mdLabel.textColor = kColor999;
            _mdLabel.text = @"描述";
            [self.contentView addSubview:_mdLabel];
        }
        
        [_userIconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.top.equalTo(self.contentView).offset(19);
            make.size.mas_equalTo(CGSizeMake(kProjectTaskListViewCell_UserIconWidth,
                                             kProjectTaskListViewCell_UserIconWidth));
        }];

        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(19-3);
            make.left.equalTo(self.userIconView.mas_right).offset(kInnerHorizonOffset);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(20);
        }];
        
        [_numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView).offset(-10);
            make.left.equalTo(self.userIconView.mas_right).offset(kInnerHorizonOffset);
            make.height.mas_equalTo(15);
        }];
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.numLabel.mas_right).offset(5);
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
    [_userIconView sd_setImageWithURL:[_task.owner.avatar urlImageWithCodePathResize:2*kProjectTaskListViewCell_UserIconWidth] placeholderImage:kPlaceholderMonkeyRoundWidth(kProjectTaskListViewCell_UserIconWidth)];
    _contentLabel.attributedText=[NSString getAttributeFromText:[_task.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];

    [_describeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.equalTo(self.userIconView.mas_right).offset(kInnerHorizonOffset);
        make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
        make.height.mas_equalTo([TaskSearchCell contentLabelHeightWithProjectTopic:_task]);
    }];

    //Bottom
    _numLabel.text = [NSString stringWithFormat:@"#%@", _task.resource_id.stringValue];
    _userNameLabel.text = _task.creator.name;
    _timeLabel.text = [_task.created_at stringDisplay_MMdd];
    _commentCountLabel.text = _task.comments.stringValue;
    _mdIconView.hidden = _mdLabel.hidden = !_task.has_description.boolValue;
    _describeLabel.attributedText=[NSString getAttributeFromText:[_task.descript stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] emphasizeTag:@"em" emphasizeColor:[UIColor colorWithHexString:@"0xE84D60"]];
}


+ (CGFloat)cellHeightWithObj:(id)obj {
    Task *task = (Task *)obj;
    return kBaseCellHeight+[TaskSearchCell contentLabelHeightWithProjectTopic:task];
}

+ (CGFloat)contentLabelHeightWithProjectTopic:(Task *)task{
    NSString *realContent=[NSString getStr:task.descript removeEmphasize:@"em"];
    CGFloat realheight = [realContent getHeightWithFont:kProjectTaskListViewCell_ContentFont constrainedToSize:CGSizeMake(kProjectTaskListViewCell_ContentWidth, 1000)];
    return MIN(realheight, kDetialContentMaxHeight);
}


@end

