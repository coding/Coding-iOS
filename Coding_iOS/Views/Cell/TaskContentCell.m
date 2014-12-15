//
//  TaskContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kTaskContentCell_PadingLeft 20.0
#define kTaskContentCell_PadingRight 20.0
#define kTaskContentCell_ContentHeightMin 100.0
#define kTextView_Pading 8.0
#define kTaskContentCell_ContentWidth (kScreen_Width-kTaskContentCell_PadingLeft-kTaskContentCell_PadingRight)
#define kTaskContentCell_ContentFont [UIFont systemFontOfSize:18]


#import "TaskContentCell.h"

@interface TaskContentCell ()
@property (strong, nonatomic) UITextView *taskContentView;
@property (strong, nonatomic) UILabel *creatorLabel;
@property (strong, nonatomic) UIButton *deleteBtn;
@end

@implementation TaskContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_taskContentView) {
            _taskContentView = [[UITextView alloc] initWithFrame:CGRectMake(kTaskContentCell_PadingLeft-kTextView_Pading, 1, kTaskContentCell_ContentWidth+kTextView_Pading*2, kTaskContentCell_ContentHeightMin)];
            _taskContentView.font = kTaskContentCell_ContentFont;
            _taskContentView.delegate = self;
            [self.contentView addSubview:_taskContentView];
        }
        if (!_creatorLabel) {
            _creatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(kTaskContentCell_PadingLeft, 0, kTaskContentCell_ContentWidth, 25)];
            _creatorLabel.font = [UIFont systemFontOfSize:12];
            _creatorLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_creatorLabel];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            self.deleteBtn.frame = CGRectMake(kScreen_Width - kTaskContentCell_PadingRight- 50 , 0, 50, 25);
            [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
            [self.deleteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
            self.deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.deleteBtn];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_task) {
        return;
    }
    _taskContentView.text = _task.content;
    CGFloat taskViewHeight = [_task.content getHeightWithFont:kTaskContentCell_ContentFont constrainedToSize:CGSizeMake(kTaskContentCell_ContentWidth, CGFLOAT_MAX)];
    taskViewHeight = MAX(taskViewHeight+kTextView_Pading*2, kTaskContentCell_ContentHeightMin);
    [_taskContentView setHeight:taskViewHeight];
    if (_task.handleType == TaskHandleTypeAdd) {
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 现在", _task.creator.name];
    }else if (_task.handleType == TaskHandleTypeEdit){
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _task.creator.name, [_task.created_at stringTimesAgo]];
    }
    [_creatorLabel setY:taskViewHeight];
    [_deleteBtn setY:taskViewHeight];
    if (_task.handleType == TaskHandleTypeAdd) {
        _deleteBtn.hidden = YES;
    }else{
        _deleteBtn.hidden = NO;
    }
}

- (void)deleteBtnClicked:(id)sender{
    if (_deleteBtnClickedBlock) {
        _deleteBtnClickedBlock(_task);
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[Task class]]) {
        Task *task = (Task *)obj;
        CGFloat taskViewHeight = [task.content getHeightWithFont:kTaskContentCell_ContentFont constrainedToSize:CGSizeMake(kTaskContentCell_ContentWidth, CGFLOAT_MAX)];
        taskViewHeight = MAX(taskViewHeight+kTextView_Pading*2, kTaskContentCell_ContentHeightMin);
        cellHeight += taskViewHeight +30;
    }
    return cellHeight;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.textViewBecomeFirstResponderBlock) {
        self.textViewBecomeFirstResponderBlock();
    }
    return YES;
}

@end
