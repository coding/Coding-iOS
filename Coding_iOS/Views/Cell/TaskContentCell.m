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
@property (strong, nonatomic) UIButton *deleteBtn, *descriptionBtn;
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
            [_taskContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, kTaskContentCell_PadingLeft-kTextView_Pading, 40, kTaskContentCell_PadingLeft-kTextView_Pading));
            }];
        }
        if (!self.deleteBtn) {
            self.deleteBtn = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.layer.cornerRadius = 5.0;
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexString:@"0xdadada"].CGColor;
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                [button setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
                [button setTitle:@"删除" forState:UIControlStateNormal];
                [button addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            
                [self.contentView addSubview:button];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(44, 27));
                    make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
                    make.right.equalTo(self.contentView.mas_right).offset(-kTaskContentCell_PadingRight);
                }];
                button;
            });
        }
        if (!self.descriptionBtn) {
            self.descriptionBtn = ({
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.layer.cornerRadius = 5.0;
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithHexString:@"0xdadada"].CGColor;
                button.titleLabel.font = [UIFont systemFontOfSize:13];
                [button addTarget:self action:@selector(descriptionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:button];
                
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(79, 27));
                    make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
                    make.left.equalTo(self.contentView.mas_left).offset(kTaskContentCell_PadingLeft);
                }];
                button.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
                button.imageEdgeInsets = UIEdgeInsetsMake(0, 52, 0, -52);
                button;
            });
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
    
    if (_task.handleType == TaskHandleTypeAdd) {
        _deleteBtn.hidden = YES;
        [_descriptionBtn setImage:[UIImage imageNamed:@"taskDescription_add_arrow"] forState:UIControlStateNormal];
        [_descriptionBtn setTitle:@"添加描述" forState:UIControlStateNormal];
        [_descriptionBtn setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateNormal];
    }else{
        _deleteBtn.hidden = NO;
        [_descriptionBtn setImage:[UIImage imageNamed:@"taskDescription_check_arrow"] forState:UIControlStateNormal];
        [_descriptionBtn setTitle:(_task.has_description.boolValue? @"查看描述": @"补充描述") forState:UIControlStateNormal];
        [_descriptionBtn setTitleColor:[UIColor colorWithHexString:@"0x3bbd79"] forState:UIControlStateNormal];
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
    if ([obj isKindOfClass:[Task class]]) {
        Task *task = (Task *)obj;
        CGFloat taskViewHeight = [task.content getHeightWithFont:kTaskContentCell_ContentFont constrainedToSize:CGSizeMake(kTaskContentCell_ContentWidth, CGFLOAT_MAX)];
        taskViewHeight = MAX(taskViewHeight+kTextView_Pading*2, kTaskContentCell_ContentHeightMin);
        cellHeight += taskViewHeight +40;
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
