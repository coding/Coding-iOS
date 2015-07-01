//
//  TaskContentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-19.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kTaskContentCell_ContentHeightMin kScaleFrom_iPhone5_Desgin(90.0)
#define kTextView_Pading 8.0
#define kTaskContentCell_ContentWidth (kScreen_Width-kPaddingLeftWidth-kPaddingLeftWidth + 2*kTextView_Pading)
#define kTaskContentCell_ContentFont [UIFont systemFontOfSize:18]


#import "TaskContentCell.h"

@interface TaskContentCell ()
@property (strong, nonatomic) UITextView *taskContentView;
@property (strong, nonatomic) UIButton *deleteBtn;
@property (strong, nonatomic) UILabel *creatorLabel;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation TaskContentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_taskContentView) {
            _taskContentView = [[UITextView alloc] initWithFrame:CGRectZero];
            _taskContentView.backgroundColor = [UIColor clearColor];
            _taskContentView.font = kTaskContentCell_ContentFont;
            _taskContentView.delegate = self;
            [self.contentView addSubview:_taskContentView];
        }
        if (!_creatorLabel) {
            _creatorLabel = [[UILabel alloc] init];
            _creatorLabel.font = [UIFont systemFontOfSize:12];
            _creatorLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            [self.contentView addSubview:_creatorLabel];
        }
        if (!_deleteBtn) {
            _deleteBtn = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                [button setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
                [button setTitle:@"删除" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:button];
                button;
            });
        }
        if (!_lineView) {
            _lineView = [[UIView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 0, kScreen_Width - 2*kPaddingLeftWidth, 0.5)];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
        }
        [_taskContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, kPaddingLeftWidth-kTextView_Pading, 35, kPaddingLeftWidth-kTextView_Pading));
        }];
        [_creatorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(kPaddingLeftWidth);
            make.right.equalTo(_deleteBtn.mas_left).offset(10);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.height.mas_equalTo(20);
        }];
        
        [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 20));
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.right.equalTo(self.contentView.mas_right).offset(-kPaddingLeftWidth);
        }];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(kPaddingLeftWidth);
            make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_task) {
        return;
    }
    _taskContentView.text = _task.content;
    
    if (_task.handleType > TaskHandleTypeEdit) {
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 现在", _task.creator.name];
        _deleteBtn.hidden = YES;
    }else{
        _creatorLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _task.creator.name, [_task.created_at stringTimesAgo]];
        _deleteBtn.hidden = !([_task.creator.global_key isEqualToString:[Login curLoginUser].global_key] || _task.project.owner_id.integerValue == [Login curLoginUser].id.integerValue);
    }
}

- (void)deleteBtnClicked:(id)sender{
    if (_deleteBtnClickedBlock) {
        _deleteBtnClickedBlock(_task);
    }
}
- (void)descriptionBtnClicked:(id)sender{
    if (_descriptionBtnClickedBlock) {
        _descriptionBtnClickedBlock(_task);
    }
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    cellHeight += kTaskContentCell_ContentHeightMin + 40;
//    if ([obj isKindOfClass:[Task class]]) {
//        Task *task = (Task *)obj;
//        CGFloat taskViewHeight = [task.content getHeightWithFont:kTaskContentCell_ContentFont constrainedToSize:CGSizeMake(kTaskContentCell_ContentWidth, CGFLOAT_MAX)];
//        taskViewHeight = MAX(taskViewHeight+kTextView_Pading*2, kTaskContentCell_ContentHeightMin);
//        cellHeight += taskViewHeight +40;
//    }
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
